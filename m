From: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Subject: Re: [patch 2.6.24-git] net/enc28j60: oops fix, low power mode
Date: Mon, 11 Feb 2008 13:07:54 +0100
Message-ID: <47B03A9A.2060605@eptar.com>
References: <20080205190124.E72F48E45F@adsl-69-226-248-13.dsl.pltn13.pacbell.net> <200802062156.41862.david-b@pacbell.net> <47AAE32A.7070105@eptar.com> <200802100954.18225.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fe-relay04.albacom.net ([217.220.57.147]:40208 "EHLO
	fe-relay04.albacom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752620AbYBKMGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 07:06:45 -0500
In-Reply-To: <200802100954.18225.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Brownell wrote:

>> > and in  the enc28j60_net_close() after enc28j60_hw_disable().
>> > Probably we don't need to set_lowpower(false) in enc28j60_net_open() since
>> > it performs a soft reset with enc28j60_hw_init() (not sure).
>>     
>
> The current patch sets the device in low power mode in hw_disable(),
> and takes it out of that mode in hw_enable().  I can move them; and
> the only "soft" thing about this chip's reset is when it starts from
> a protocol command not the reset command.
>
>   
I want to mean the reset software command. It's functionally
equivalent to hardware system reset, but it seems to need exit low
power mode to work flawlessly.
I have tried your latest patch. Only after the following change it
works fine (no more rx errors during ifconfig up).
I added enc28j60_lowpower(false) just before enc28j60_hw_init()

@@ -1318,8 +1347,9 @@
         }
         return -EADDRNOTAVAIL;
     }
-    /* Reset the hardware here */
+    /* Reset the hardware here (and take it out of low power mode) */
     enc28j60_hw_disable(priv);
+    enc28j60_lowpower(priv, false);
     if (!enc28j60_hw_init(priv)) {
         if (netif_msg_ifup(priv))
             dev_err(&dev->dev, "hw_reset() failed\n");

With this addition you can add Acked-by line.
Thank you.
>> After a couple of :
>>
>> ifconfig eth0 down
>> (wait just 1 second)
>> ifconfig eth0 up
>>
>> the network is frozen.
>>
>> If I do another
>> ifconfig eth0 down
>> (wait just 1 second)
>> ifconfig eth0 up
>>
>> restarts.
>> It's random, no rule.
>>     
>
> I write a shell loop to do that, and added a "ping -c2" too.
> If that was done before the "sleep 1" no packets flowed.
> Afterwards, no problem -- ever. 
>
> (And outside the loop, "ethool -s eth1 duplex full".)
>
>
>   
I forgot to tell that during my test I have a web server running on the 
board and
a client continuously requesting a page.

