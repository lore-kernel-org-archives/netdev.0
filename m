From: Helge Deller <deller@gmx.de>
Subject: Re: [PATCH] Time-based RFC 4122 UUID generator
Date: Tue, 20 Nov 2007 23:40:29 +0100
Message-ID: <200711202340.29287.deller@gmx.de>
References: <200711182038.22055.deller@gmx.de> <20071119221559.2f4bdb26.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Theodore Tso <tytso@mit.edu>,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:47268 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1758066AbXKTWkr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 17:40:47 -0500
In-Reply-To: <20071119221559.2f4bdb26.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 20 November 2007, Andrew Morton wrote:
> On Sun, 18 Nov 2007 20:38:21 +0100 Helge Deller <deller@gmx.de> wrote:
> 
> > Andrew,
> > 
> > could you please consider adding this patch to your 2.6.25 patch series?
> 
> please cc netdev on networking-related things

Ok.
 
> > This is the third version of the patch in which I cleaned up and fixed quite some stuff according to feedback from Ted.
> > I assume this version is OK, since I didn't received any further feedback since two weeks: http://lkml.org/lkml/2007/11/4/128.
> > 
> > Thanks,
> > Helge
> > -------
> > Title: Add time-based RFC 4122 UUID generator
> > 
> > The current Linux kernel currently contains the generate_random_uuid() 
> > function, which creates - based on RFC 4122 - truly random UUIDs and 
> > provides them to userspace through /proc/sys/kernel/random/boot_id and 
> > /proc/sys/kernel/random/uuid.
> > 
> > This patch additionally adds the "Time-based UUID" variant of RFC 4122, 
> > with which userspace applications can easily get real unique time-based 
> > UUIDs through /proc/sys/kernel/random/uuid_time.
> > A new /proc/sys/kernel/random/uuid_time_clockseq sysfs entry is available,
> > so that the clock_seq value can be retained across system bootups (which
> > is required by RFC 4122).
> > 
> > The attached implementation uses getnstimeofday() to get very fine-grained
> > granularity. This helps, so that userspace tools can get a lot more UUIDs 
> > (if needed) per time than before.
> > A mutex takes care of the proper locking against a mistaken double creation 
> > of UUIDs for simultanious running processes.
> > 
> > Signed-off-by: Helge Deller <deller@gmx.de>
> > 
> >  drivers/char/random.c  |  205 ++++++++++++++++++++++++++++++++++++++++++++-----
> >  include/linux/sysctl.h |    5 -
> >  2 files changed, 190 insertions(+), 20 deletions(-)
> > 
> > diff --git a/drivers/char/random.c b/drivers/char/random.c
> > index 5fee056..fc48c29 100644
> > --- a/drivers/char/random.c
> > +++ b/drivers/char/random.c
> > @@ -6,6 +6,9 @@
> >   * Copyright Theodore Ts'o, 1994, 1995, 1996, 1997, 1998, 1999.  All
> >   * rights reserved.
> >   *
> > + * Time based UUID (RFC 4122) generator:
> > + * Copyright Helge Deller <deller@gmx.de>, 2007
> > + *
> >   * Redistribution and use in source and binary forms, with or without
> >   * modification, are permitted provided that the following conditions
> >   * are met:
> > @@ -239,6 +242,7 @@
> >  #include <linux/spinlock.h>
> >  #include <linux/percpu.h>
> >  #include <linux/cryptohash.h>
> > +#include <linux/if_arp.h>
> >  
> >  #include <asm/processor.h>
> >  #include <asm/uaccess.h>
> > @@ -1174,12 +1178,169 @@ EXPORT_SYMBOL(generate_random_uuid);
> >  static int min_read_thresh = 8, min_write_thresh;
> >  static int max_read_thresh = INPUT_POOL_WORDS * 32;
> >  static int max_write_thresh = INPUT_POOL_WORDS * 32;
> > -static char sysctl_bootid[16];
> > +static unsigned char sysctl_bootid[16] __read_mostly;
> >  
> >  /*
> > - * These functions is used to return both the bootid UUID, and random
> > - * UUID.  The difference is in whether table->data is NULL; if it is,
> > - * then a new UUID is generated and returned to the user.
> > + * Helper functions and variables for time based UUID generator
> > + */
> > +static unsigned int clock_seq;
> > +static const unsigned int clock_seq_max = 0x3fff; /* 14 bits */
> 
> There isn't a lot of point in `static const'.  Hopefully the compiler will
> do the right thing with it (use literal constant and elide the storage if
> nothing takes its address) but why not just do #define UPPER_CASE_THING in
> the time-homoured manner?

Thanks. I'll fix this with a #define.
 
> > +static int clock_seq_initialized __read_mostly;
> > +
> > +static void init_clockseq(void)
> > +{
> > +	get_random_bytes(&clock_seq, sizeof(clock_seq));
> > +	clock_seq &= clock_seq_max;
> > +	clock_seq_initialized = 1;
> > +}
> > +
> > +static int proc_dointvec_clockseq(struct ctl_table *table, int write,
> > +		struct file *filp, void __user *buffer,
> > +		size_t *lenp, loff_t *ppos)
> > +{
> > +	int ret;
> > +
> > +	if (!write && !clock_seq_initialized)
> > +		init_clockseq();
> 
> Seems there's a straightfroward race here where multiple tasks can run
> init_clockseq() concurrently.
> 
> Can't we use a regular initcall here and make init_clockseq() __init?  I
> guess that would cast doubt over the quality of the thing which
> get_random_bytes() returned, but that's already the case - super-early
> userspace in initramfs could mount /proc and trigger this call.  We end up
> with a predictable sequence number?

Ok, I'll change that to an initcall. 
It's possible for userspace to write a new random new clock_seq value to
/proc/sys/kernel/random/uuid_time_clockseq at any time at bootup, although
this shouldn't be necessary at all if the clock is correct at the time the first
UUID is asked for.
So, in principle it shouldn't be a big problem if it's an initcall.

> > +	ret = proc_dointvec(table, write, filp, buffer, lenp, ppos);
> > +
> > +	if (write && ret >= 0) {
> > +		clock_seq_initialized = 1;
> > +		clock_seq &= clock_seq_max;
> > +	}
> > +
> > +	return ret;
> > +}
> > +
> > +/*
> > + * Generate time based UUID (RFC 4122)
> > + *
> > + * This function is protected with a mutex to ensure system-wide
> > + * uniqiness of the new time based UUID.
> > + */
> > +static void generate_random_uuid_time(unsigned char uuid_out[16])
> > +{
> > +	static DEFINE_MUTEX(uuid_mutex);
> > +	static u64 last_time_all;
> > +	static unsigned int clock_seq_started;
> > +	static unsigned char last_mac[ETH_ALEN];
> > +
> > +	struct timespec ts;
> > +	u64 time_all;
> > +	unsigned char *found_mac = NULL;
> > +	struct net_device *d __maybe_unused;
> > +	int inc_clock_seq = 0;
> > +
> > +	mutex_lock(&uuid_mutex);
> > +
> > +	/* Get the spatially unique node identifier */
> > +#ifdef CONFIG_NET
> > +	read_lock(&dev_base_lock);
> > +	for_each_netdev(&init_net, d) {
> > +		if (d->type == ARPHRD_ETHER && d->addr_len == ETH_ALEN
> > +		    && d != init_net.loopback_dev) {
> > +			if (!memcmp(&last_mac, d->dev_addr, ETH_ALEN)) {
> > +				found_mac = last_mac;
> > +				break;
> > +			}
> > +			if (!found_mac)
> > +				found_mac = d->dev_addr;
> > +		}
> > +	}
> > +	if (found_mac)
> > +		memcpy(&uuid_out[10], found_mac, ETH_ALEN);
> > +	read_unlock(&dev_base_lock);
> > +#endif

> hm.  Maybe that should be a helper function over in net/, dunno.

Me neither :-)
If people here prefer, I'll come up with a patch for net/.

What this code basically does is:
- Look if a net device with a given MAC still exists in this machine. If yes, return this MAC again.
- If it does not exist any longer, return the MAC address of the _first_ true network card
- If no network card exists at all, return e.g. 'false' (in which case the UUID function will use a random MAC).

What does the network people here think ? Should this be a helper function in net/ ?

> So you're assuming that the first-encountered netdev's mac address is a
> globally-unique number?  That's a key design decision and should 100%
> have appeared front-and-centre in the changelog.

Basically that's just the steps the RFC describes. I just sticked to the RFC.
The RFC is aware, that it's probably not globally-unique, that's why a 'clock_seq' number and 
the time stamp adds some more 'uniqueness' to the full UUID.

> Is it true?  It may be true in a practial sense, but perhaps in some
> private networking environments some organisations have duplicated mac
> addresses?
> 
> What are the implications of this assumption being false?

See above. Only all pieces together (timestamp + clock_seq + MAC) builds up 
the full UUID.
The timestamp value is the current time, and clock_seq is a random value. 
MAC is preferrably a real MAC, or if not available a random MAC-like number.

> > +	if (unlikely(!found_mac)) {
> > +		/* use bootid's nodeID if no network interface found */
> > +		if (sysctl_bootid[8] == 0)
> > +			generate_random_uuid(sysctl_bootid);
> > +		memcpy(&uuid_out[10], &sysctl_bootid[10], ETH_ALEN);
> > +	}
> 
> What is "bootid's nodeID"?

Acording to the RFC you should generate a random number and use it 
as MAC, if no network device was found.
The current Linux kernel generates a "random unique boot ID" for
/proc/sys/kernel/random/uuid, and the last part of this UUID is the 
"bootid/nodeID" (a random MAC). It's then used by my code if no 
network card is found.
 
> I guess I could work it out, but again, this is a core design decision and
> it should be properly covered in your changelog so we can
> understand what your thinking is here.

Yes. Basically it's just the RFC 4122 implementation, but I'll better describe 
it with the next patch.

> > +	/* if MAC/NodeID changed, create a new clock_seq value */
> > +	if (unlikely(found_mac != last_mac &&
> > +		     memcmp(&last_mac, &uuid_out[10], ETH_ALEN))) {
> > +			memcpy(&last_mac, &uuid_out[10], ETH_ALEN);
> > +			inc_clock_seq = 1;
> > +	}
> 
> etc.
> 
> > +	/* Determine 60-bit timestamp value. For UUID version 1, this is
> > +	 * represented by Coordinated Universal Time (UTC) as a count of 100-
> > +	 * nanosecond intervals since 00:00:00.00, 15 October 1582 (the date of
> > +	 * Gregorian reform to the Christian calendar).
> > +	 */
> > +advance_time:
> > +	getnstimeofday(&ts);
> > +	time_all = ((u64) ts.tv_sec) * (NSEC_PER_SEC/100);
> > +	time_all += ts.tv_nsec / 100;
> > +
> > +	/* add offset from Gregorian Calendar to Jan 1 1970 */
> > +	time_all += 12219292800000ULL * (NSEC_PER_MSEC/100);
> > +	time_all &= 0x0fffffffffffffffULL; /* limit to 60 bits */
> > +
> > +	/* Determine clock sequence (max. 14 bit) */
> > +	if (unlikely(!clock_seq_initialized)) {
> > +		init_clockseq();
> > +		clock_seq_started = clock_seq;
> > +	} else {
> > +		if (unlikely(inc_clock_seq || time_all <= last_time_all)) {
> > +			clock_seq = (clock_seq+1) & clock_seq_max;
> > +			if (unlikely(clock_seq == clock_seq_started)) {
> > +				clock_seq = (clock_seq-1) & clock_seq_max;
> > +				goto advance_time;
> > +			}
> > +		} else
> > +			clock_seq_started = clock_seq;
> > +	}
> > +	last_time_all = time_all;
> > +
> > +	/* Fill in timestamp and clock_seq values */
> > +	uuid_out[3] = (u8) time_all;
> > +	uuid_out[2] = (u8) (time_all >> 8);
> > +	uuid_out[1] = (u8) (time_all >> 16);
> > +	uuid_out[0] = (u8) (time_all >> 24);
> > +	uuid_out[5] = (u8) (time_all >> 32);
> > +	uuid_out[4] = (u8) (time_all >> 40);
> > +	uuid_out[7] = (u8) (time_all >> 48);
> > +	uuid_out[6] = (u8) (time_all >> 56);
> > +
> > +	uuid_out[8] = clock_seq >> 8;
> > +	uuid_out[9] = clock_seq & 0xff;
> > +
> > +	/* Set UUID version to 1 --- time-based generation */
> > +	uuid_out[6] = (uuid_out[6] & 0x0F) | 0x10;
> > +	/* Set the UUID variant to DCE */
> > +	uuid_out[8] = (uuid_out[8] & 0x3F) | 0x80;
> > +
> > +	mutex_unlock(&uuid_mutex);
> > +}
> > +
> > +
> > +/*
> > + * Get UUID based on requested type.
> > + */
> > +static unsigned char *get_uuid(void *extra1, unsigned char *uuid)
> > +{
> > +	switch ((int) extra1) {
> > +	case RANDOM_BOOT_ID:
> > +		uuid = sysctl_bootid;
> > +		if (unlikely(uuid[8] == 0))
> > +			generate_random_uuid(uuid);
> > +		break;
> > +	case RANDOM_UUID:
> > +		generate_random_uuid(uuid);
> > +		break;
> > +	case RANDOM_UUID_TIME:
> > +		generate_random_uuid_time(uuid);
> > +		break;
> > +	}
> > +	return uuid;
> > +}
> > +
> > +/*
> > + * These functions are used to return the bootid UUID, random UUID and
> > + * time based UUID.
> >   *
> >   * If the user accesses this via the proc interface, it will be returned
> >   * as an ASCII string in the standard UUID format.  If accesses via the
> > @@ -1191,13 +1352,13 @@ static int proc_do_uuid(ctl_table *table, int write, struct file *filp,
> >  	ctl_table fake_table;
> >  	unsigned char buf[64], tmp_uuid[16], *uuid;
> >  
> > -	uuid = table->data;
> > -	if (!uuid) {
> > -		uuid = tmp_uuid;
> > -		uuid[8] = 0;
> > +	/* random/time UUIDs need to be read completely at once */
> > +	if ((int)table->extra1 != RANDOM_BOOT_ID && *ppos > 0) {
> > +		*lenp = 0;
> > +		return 0;
> >  	}
> > -	if (uuid[8] == 0)
> > -		generate_random_uuid(uuid);
> > +
> > +	uuid = get_uuid(table->extra1, tmp_uuid);
> >  
> >  	sprintf(buf, "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-"
> >  		"%02x%02x%02x%02x%02x%02x",
> > @@ -1221,13 +1382,7 @@ static int uuid_strategy(ctl_table *table, int __user *name, int nlen,
> >  	if (!oldval || !oldlenp)
> >  		return 1;
> >  
> > -	uuid = table->data;
> > -	if (!uuid) {
> > -		uuid = tmp_uuid;
> > -		uuid[8] = 0;
> > -	}
> > -	if (uuid[8] == 0)
> > -		generate_random_uuid(uuid);
> > +	uuid = get_uuid(table->extra1, tmp_uuid);
> >  
> >  	if (get_user(len, oldlenp))
> >  		return -EFAULT;
> > @@ -1284,11 +1439,11 @@ ctl_table random_table[] = {
> >  	{
> >  		.ctl_name	= RANDOM_BOOT_ID,
> >  		.procname	= "boot_id",
> > -		.data		= &sysctl_bootid,
> >  		.maxlen		= 16,
> >  		.mode		= 0444,
> >  		.proc_handler	= &proc_do_uuid,
> >  		.strategy	= &uuid_strategy,
> > +		.extra1		= (void *) RANDOM_BOOT_ID,
> >  	},
> >  	{
> >  		.ctl_name	= RANDOM_UUID,
> > @@ -1297,6 +1452,20 @@ ctl_table random_table[] = {
> >  		.mode		= 0444,
> >  		.proc_handler	= &proc_do_uuid,
> >  		.strategy	= &uuid_strategy,
> > +		.extra1		= (void *) RANDOM_UUID,
> > +	},
> > +	{
> > +		.procname	= "uuid_time",
> > +		.mode		= 0444,
> > +		.proc_handler	= &proc_do_uuid,
> > +		.extra1		= (void *) RANDOM_UUID_TIME,
> > +	},
> > +	{
> > +		.procname	= "uuid_time_clockseq",
> > +		.data		= &clock_seq,
> > +		.maxlen		= sizeof(unsigned int),
> > +		.mode		= 0644,
> > +		.proc_handler	= &proc_dointvec_clockseq,
> >  	},
> >  	{ .ctl_name = 0 }
> >  };
> > diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
> > index e99171f..dd09d97 100644
> > --- a/include/linux/sysctl.h
> > +++ b/include/linux/sysctl.h
> > @@ -248,8 +248,9 @@ enum
> >  	RANDOM_ENTROPY_COUNT=2,
> >  	RANDOM_READ_THRESH=3,
> >  	RANDOM_WRITE_THRESH=4,
> > -	RANDOM_BOOT_ID=5,
> > -	RANDOM_UUID=6
> > +	RANDOM_BOOT_ID=5,	/* rfc4122 version 4, boot UUID */
> > +	RANDOM_UUID=6,		/* rfc4122 version 4, random-based */
> > +	RANDOM_UUID_TIME=7	/* rfc4122 version 1, time-based */
> >  };
> 
> 
