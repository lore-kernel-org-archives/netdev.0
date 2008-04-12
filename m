From: Gertjan Hofman <gertjan_hofman@yahoo.com>
Subject: Re: VLAN & ARP requests fail for ARM EABI (2.6.24)
Date: Sat, 12 Apr 2008 09:58:32 -0700 (PDT)
Message-ID: <719893.13386.qm@web32602.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web32602.mail.mud.yahoo.com ([68.142.207.229]:26640 "HELO
	web32602.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753776AbYDLQ6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2008 12:58:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick,

Ben mentioned you might be the person to talk to. Just to make sure I did what you suggested:

From:  http://devresources.linux-foundation.org/dev/iproute2/download/   I downloaded:
iproute2-2.6.24-rc7.tar.bz2       08-Jan-2008 09:06  336K  and cross compiled EABI.

I created the VLAN with:

 ./ip link add link eth0 eth0.0  type vlan id 0   (did I get the syntax correct  ?)

/proc/net/vlan/ indicated eth0.0 is there and looks fine.


Unfortunately pinging through a VLAN to this VLAN fails as before withthe same symptoms - ARP requests are received but not answered.

About OABI/EABI incompatibilities - I didnt explicitly mention it but when testing the EABI, the entire file system is EABI and when testingOABI  the entire filesystem is also OABI - so it should not be theproblem.


We spent quite of bit of time tracking this problem deeper down thestack but with limited results.  It looks like  the calling sequence is:

driver-->
  -- ?
   - ---> vlan.c 
        ---> ifnet_tx
           --->  ?
              ---->  arp.c
                    ---> (arp_process)
                      ----> ip_route_input 
                        ----> ip_route_input_slow
                          ----> fib_validate_source


Its in fib_validate_source that things go wrong.

In the EABI (faulty kernel), we print values of the device pointers, which are considered in fib_validate_source()
 FIB_RES_DEV(res) : 0xC3C77000 
 dev                          : 0xC3E2E800

These are not the same,  so the variable rpf is checked and it bails returning  -EINVAL. You can fake it, by setting rpf=0 using  echo 0>   /proc/sys/net/ipv4/conf/eth2.0/rp_filter --> 0 and then pingsfrom the foreign PC to the ARM work.  Still, pings from ARM to PC  dontwork - the ARP request goes out, but the response (which gets to arp.c)is ignored. Presumable for a similar reason - some device pointer check fails.

My guess is that there is a problem with the dev pointer all  the wayback in the vlan.c code, which only manifest itself with the EABIcompiler.
If you run the working kernel version, in   fib_validate_source:

if (in_dev) {
        no_addr = in_dev->ifa_list == NULL;
        rpf = IN_DEV_RPFILTER(in_dev);          ---->  rpfreturns 0 here eventhough the proc/sys/net/ipv4/conf/eth2.0/rp_filteris set to 1.

        if (DEBUG_XXX == 0xDEADBEEF)
          printk(KERN_INFO "*********rpf = 0x%X\n", rpf);
    }


If EABI  rpf =1 , in OABI rpf=0.  So there is something different about  the in_dev. pointer

Do you know what IN_DEV_RPFILTER(in_dev) does exactly ?   

I think I need to check the validity of the device pointer already at the VLAN level, but I am not sure how to do this. Any tips ?

Thanks

Gertjan






----- Original Message ----
From: Patrick McHardy <kaber@trash.net>
To: Gertjan Hofman <gertjan_hofman@yahoo.com>
Cc: netdev@vger.kernel.org
Sent: Wednesday, April 9, 2008 5:40:45 PM
Subject: Re: VLAN & ARP requests fail for ARM EABI (2.6.24)

Gertjan Hofman wrote:
> Dear Sirs,
> 
> Since the VLAN mailing list is closed, its author suggested I post here. 
> We have an ARM920T processor based system. When compiling the kernel 2.6.24 using OABI (and appropiate 4.1.1 cross toolchain), VLAN functionality is fine. When setting the CONFIG_EABI flag and using  the 4.2.2 toolchain (created by the OpenEmbedded project) a VLAN device fails to respond.
> 
> When pinging through the ARM VLAN device to a (PC based) VLAN device, the following is seen in the vlan driver:
> The ping request is sent out, followed by an ARP request. The PC returns the ARP reply and it is seen by the VLAN driver (vlan_skb_recv) which calls netif_rx(). This repeats a couple of pings later i.e. the arp reply is not used or received properly.
> 
> Similarly, when pinging from the PC, the ARP request is seen by vlan_skb_recv() but there is no ARP reply from the ARM cascading through the vlan driver.
> 
> It seems to me that either the issue is with the code that handles the ARP request when compiling in EABI format, or that VLAN doesnt process the frame properly and sends it on incorrectly. Recompile the kernel with OABI and everything is fine.
> 
> Note that communication works fine on either OABI or EABI when using 'normal' devices (eth0 etc). This puts the suspicion back on vlan.
> 
> 
> Since EABI changes structure packing and other things, I suspect the cause is some networking code that knows a bit too much about its size & packing.
> 
> I am happy to troubleshoot, but I am no kernel expert. Tips would be appreciated. Like how to dump the sbk buffer in both cases..


I actually have no idea about the differences between
OABI and EABI, but I know a mix of both broke some
iptables setups (kernel EABI/userspace OABI or something
like that). Could you fetch the latest iproute and try
again with adding your VLANs using iproute?

The syntax is:

ip link add link <lowerdev> [name] <name> type vlan id VID

If that works the problem is most likely an inappropriate
ABI mix.






__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 
