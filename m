From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] enhance usability of
 /proc/sys/net/ipv4/ip_local_reserved_ports (v2)
Date: Wed, 14 Mar 2012 15:20:10 -0700
Message-ID: <20120314152010.2b043cd6@nehalam.linuxnetplumber.net>
References: <4F5BE563.9050506@gmx.de>
	<4F5FAF28.5030205@gmx.de>
	<1331711033.17983.19.camel@cr0>
	<4F611669.6000903@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>,
	Octavian Purdila <octavian.purdila@intel.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Frank Danapfel <fdanapfe@redhat.com>,
	Laszlo Ersek <lersek@redhat.com>
To: Helge Deller <deller@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52086 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761299Ab2CNWUO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Mar 2012 18:20:14 -0400
In-Reply-To: <4F611669.6000903@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Mar 2012 23:06:33 +0100
Helge Deller <deller@gmx.de> wrote:

> On 03/14/2012 08:43 AM, Cong Wang wrote:
> > On Tue, 2012-03-13 at 21:33 +0100, Helge Deller wrote:
> >> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> >> index f487f25..1f60398 100644
> >> --- a/kernel/sysctl.c
> >> +++ b/kernel/sysctl.c
> >> @@ -2805,6 +2805,8 @@ static int proc_do_cad_pid(struct ctl_table *table, int write,
> >>   * We use a range comma separated format (e.g. 1,3-4,10-10) so that
> >>   * large bitmaps may be represented in a compact manner. Writing into
> >>   * the file will clear the bitmap then update it with the given input.
> >> + * If "add" or "release" is written in front of numbers or number ranges,
> >> + * the given bits will be added to or released from the existing bitmap.
> >>   *
> > 
> > What if I only write "add" or "release" ("add ", "release " too) into
> > this file? Make sure you have tested this corner case.
> 
> Sure, I tested this case. It will not modify the the current port list.
> 
> But there were other cases which I initially didn't took care of, mostly 
> because I wanted to keep the parser simple.
> Now, in the next version of the patch the following cases will be handled
> correctly: 
> - "add release 100"		(->syntax error)
> - "release 100 add 100"		(->with all in one line the result will not be
> 		as expected because first bitmap_or() and then bitmap_andnot()
> 		will be executed, so that the 100th bit becomes released instead
> 		of added. Users will need to split this into two echo commands
> 		otherwise -EINVAL will be returned.)
> 
> >>   * Returns 0 on success.
> >>   */
> >> @@ -2813,11 +2815,13 @@ int proc_do_large_bitmap(struct ctl_table *table, int write,
> >>  {
> >>  	int err = 0;
> >>  	bool first = 1;
> >> +	bool add_or_release = 0, xrelease = 0;
> >>  	size_t left = *lenp;
> >>  	unsigned long bitmap_len = table->maxlen;
> >>  	unsigned long *bitmap = (unsigned long *) table->data;
> >> -	unsigned long *tmp_bitmap = NULL;
> >> -	char tr_a[] = { '-', ',', '\n' }, tr_b[] = { ',', '\n', 0 }, c;
> >> +	unsigned long *tmp_bitmap = NULL, *release_bitmap = NULL;
> >> +	char tr_a[] = { '-', ',', ' ', '\n' },
> >> +	     tr_b[] = { ',', ' ', '\n', 0 }, c;
> >>  
> >>  	if (!bitmap_len || !left || (*ppos && !write)) {
> >>  		*lenp = 0;
> >> @@ -2841,8 +2845,9 @@ int proc_do_large_bitmap(struct ctl_table *table, int write,
> >>                  }
> >>  		kbuf[left] = 0;
> >>  
> >> -		tmp_bitmap = kzalloc(BITS_TO_LONGS(bitmap_len) * sizeof(unsigned long),
> >> -				     GFP_KERNEL);
> >> +		tmp_bitmap = kzalloc(2 * BITS_TO_LONGS(bitmap_len) *
> >> +					sizeof(unsigned long), GFP_KERNEL);
> >> +		release_bitmap = &tmp_bitmap[BITS_TO_LONGS(bitmap_len)];
> > 
> > So you double the size, and give the second half to 'release_bitmap',
> > this will waste spaces when release_bitmap is short, right?
> 
> Yes.
> 
> > *I think* we
> > can check if we want to release any bitmaps first, and then only
> > allocate one of tmp_bitmap and release_bitmap.
> 
> The simpliest solution would be to use strcasestr(kbuf,"release") but
> this function isn't available in the kernel.
> Alternatively I could just search for e.g. upper- and lowercase 
> "release", but I don't like that either. 
> Maybe you have a better idea?
> 
> Overall, 65536 bits (ports) for the ip_local_reserved_ports bitfield
> occupies 8K. With my patch this now becomes 16K. For desktop/server
> usages I think this is OK, esp. since it's only used temporarily and
> freed directly after usage again.
> 
> >>  		if (!tmp_bitmap) {
> >>  			free_page(page);
> >>  			return -ENOMEM;
> >> @@ -2850,7 +2855,32 @@ int proc_do_large_bitmap(struct ctl_table *table, int write,
> >>  		proc_skip_char(&kbuf, &left, '\n');
> >>  		while (!err && left) {
> >>  			unsigned long val_a, val_b;
> >> -			bool neg;
> >> +			bool neg, found;
> >> +
> >> +			left -= proc_skip_spaces(&kbuf);
> >> +			if (!left)
> >> +				continue;
> >> +
> >> +			if (first || add_or_release) {
> >> +				found = (0 == strnicmp(kbuf, "add ", 4));
> >> +				if (found) {
> > 
> > I think we don't need an extra variable 'found' here.
> 

This is getting to be a text book example of why /proc is ugly
as a general purpose API.
