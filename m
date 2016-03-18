From: Alexander Graf <agraf@suse.de>
Subject: Re: [PATCH] qeth: Default to allow promiscuous mode
Date: Fri, 18 Mar 2016 10:36:40 +0100
Message-ID: <56EBCC28.5090500@suse.de>
References: <1458234085-217667-1-git-send-email-agraf@suse.de>
 <201603171752.u2HHq7hM025196@d06av11.portsmouth.uk.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org,
	heicars2@linux.vnet.ibm.com, mschwid2@linux.vnet.ibm.com,
	Ursula Braun <ubraun@linux.vnet.ibm.com>, ihno@suse.de,
	mt@suse.com, pwieczorkiewicz@suse.de,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Evgeny Cherkashin <Eugene.Crosser@ru.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201603171752.u2HHq7hM025196@d06av11.portsmouth.uk.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 17.03.16 18:52, Evgeny Cherkashin wrote:
> Hello all,
> 
> -----Alexander Graf <agraf@suse.de> wrote: -----
> 
>> To: linux-s390@vger.kernel.org
>> From: Alexander Graf <agraf@suse.de>
>> Date: 2016-03-17 20:01
>> Cc: Evgeny Cherkashin/Russia/IBM@IBMRU, linux-kernel@vger.kernel.org,
>> Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky
>> <schwidefsky@de.ibm.com>, Ursula Braun <ubraun@linux.vnet.ibm.com>,
>> ihno@suse.de, mt@suse.com, pwieczorkiewicz@suse.de
>> Subject: [PATCH] qeth: Default to allow promiscuous mode
>>
>> When a qeth device is in bridge role, one of the ports of an adapter
>> can
>> ask for promiscuous mode and get it enabled.
>>
>> The default until now was to not allow user space to enable
>> promiscuous mode
>> without switching sysfs attributes as well though, diverging from
>> usual
>> network device semantics.
>>
>> This patch sets the default to allow promiscuous enablement. That way
>> all
>> existing tools "just work", albeit only one port of an adapter can be
>> in
>> promiscuous mode at a given time.
>>
>> Signed-off-by: Alexander Graf <agraf@suse.de>
>> ---
>> drivers/s390/net/qeth_l2_sys.c | 4 ++++
>> 1 file changed, 4 insertions(+)
>>
>> diff --git a/drivers/s390/net/qeth_l2_sys.c
>> b/drivers/s390/net/qeth_l2_sys.c
>> index 692db49..98c7ac5 100644
>> --- a/drivers/s390/net/qeth_l2_sys.c
>> +++ b/drivers/s390/net/qeth_l2_sys.c
>> @@ -258,6 +258,10 @@ void qeth_l2_setup_bridgeport_attrs(struct
>> qeth_card *card)
>> 		return;
>> 	if (!card->options.sbp.supported_funcs)
>> 		return;
>> +
>> +	/* Allow to set promiscuous by default */
>> +	card->options.sbp.reflect_promisc = 1;
>> +
>> 	if (card->options.sbp.role != QETH_SBP_ROLE_NONE) {
>> 		/* Conditional to avoid spurious error messages */
>> 		qeth_bridgeport_setrole(card, card->options.sbp.role);
>> -- 
>> 1.8.5.6
>>
>>
> 
> 1. The patch changes the default behaviour (which is, on s390, to ignore promisc setting) and has potential to break existing setups. One potentially dangerous scenario is that a Linux instance may inadvertently snatch the BRIDGEPORT role from a zVM VSWITCH that bridges the HiperSockets LAN to the outer world, disrupting connectivity for many users.

Look at it the other way around. Hardware allows you to do X, why should
Linux prevent you from doing X then?

If you can break another LPAR on the system, then your virtualization
solution sucks and people should be aware of it and simply configure it
in a way that it doesn't. If you can't trust your admin of a Linux
system to call the right commands, you can't trust him to not be
malicious either and break it on purpose.

> 2. The patch sets the reflect_promisc field without setting the reflect_promisc_primary field, making it unclear to the user what is the default role. (It will be "secondary" but it's better to set it explicitly.)

I can send it explicitly if that makes it move obvious, sure.

> 3. The patch should probably go via the -networking maillist.

Ah, get_maintainers.pl didn't list it. You may want to send a patch for
the MAINTAINERS file here :).

> It seems to me that it would be better to use the sysfs attribute from a startup script or a udev rule, *only* when the system configuration requires "real" promiscuous mode, e.g. when the interface is a member of a software bridge.

You've now successfully added a lot of headaches, curses and pain to the
plate of the admin of such a system. As an admin of such a system, I
don't want to have to deal with s390x specifics. That's why I'm using
Linux there.

And who decides what "real" promiscuous mode is? Nobody should set a
network device into promiscuous mode today already unless it's required.

The current thinking in your company seems to be that "real" users
should explicitly set sysfs attribute. Let's think this a bit ahead.
Imagine a world with this sysfs attribute. Every "real" user of
promiscuous mode will now set the sysfs attribute as well in parallel to
setting promiscuous mode on the device. Once you have patched 50 user
space packages to touch something they really shouldn't have to care
about, the same applications that today set an interface to promiscuous
mode, set it to promiscuous mode, just by writing to sysfs plus enabling it.

So at the end of the day, the only thing you've done is you've created a
lot of work for people who are not you, for no gain.

That leaves only one option. We can create a udev rule that *always*
sets the device to promiscuous capable. But that's the same net result
as the patch I've sent, no?


Alex
