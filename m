From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: e1000e fails after several S3 resumes (2.6.26
	Debian, TP T60)
Date: Thu, 23 Oct 2008 15:42:55 -0700
Message-ID: <F169D4F5E1F1974DBFAFABF47F60C10A069DFD62@orsmsx507.amr.corp.intel.com>
References: Your message of "Wed, 22 Oct 2008 09:29:21 PDT."
	<4807377b0810220929v5906b42bgf9d63215370e5ab5@mail.gmail.com>
	(sfid-20081022_141704_643135_AA4BDC9C)
	<E1Kt0Cr-0008PB-Ux@approx.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	NetDEV list <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Sanjoy Mahajan <sanjoy@MIT.EDU>, Jesse Brandeburg
	<jesse.brandeburg@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <E1Kt0Cr-0008PB-Ux@approx.mit.edu>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Sanjoy Mahajan wrote:
>> There is also lots of opportunity for BIOS bugs to be effecting
>> things so please make sure that you have the latest bios.
> 
> I was about to burn the CD to update the bios to 2.23 when the failure
> recurred.  So, with the caveat that the bios is still 2.20, I've
> attached logs from ethregs and ethtool before and after
>   ethtool -r eth0
> (which fixed the dhcp).
> 
> Here is the e1000e driver version:
> 
>   $ grep e1000e /var/log/dmesg
>   [   23.988317] e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
>   [   23.988390] e1000e: Copyright (c) 1999-2008 Intel Corporation.
>   [   23.988505] e1000e 0000:02:00.0: Disabling L1 ASPM

hm, does your kernel have CONFIG_PM defined?  if it happens again please include lspci -vvv before and after ethtool -r (see below)

> Here are diffs of the attached before and after logs:
> 
> --- ethtool-before.log	2008-10-23 09:14:41.000000000 -0400
> +++ ethtool-after.log	2008-10-23 09:17:54.000000000 -0400
> @@ -33,8 +33,8 @@
>        Pass MAC control frames:           don't pass
>        Receive buffer size:               2048
>  0x02808: RDLEN (Receive desc length)     0x00001000
> -0x02810: RDH   (Receive desc head)       0x000000BB
> -0x02818: RDT   (Receive desc tail)       0x000000B9
> +0x02810: RDH   (Receive desc head)       0x00000051
> +0x02818: RDT   (Receive desc tail)       0x0000004F

this indicates the device was actually receiving packets okay (RDH) and the
driver was returning buffers to hardware (RDT)

>  0x02820: RDTR  (Receive delay timer)     0x00000000
>  0x00400: TCTL (Transmit ctrl register)   0x3103F0FA
>        Transmitter:                       enabled
> @@ -42,7 +42,7 @@
>        Software XOFF Transmission:        disabled
>        Re-transmit on late collision:     enabled
>  0x03808: TDLEN (Transmit desc length)    0x00001000
> -0x03810: TDH   (Transmit desc head)      0x00000018
> -0x03818: TDT   (Transmit desc tail)      0x00000018
> +0x03810: TDH   (Transmit desc head)      0x00000075
> +0x03818: TDT   (Transmit desc tail)      0x00000075

device was also claiming successfully transmitting, so I don't know why 
the DHCP packets don't work, can you tcpdump on the network or the dhcp 
server by chance?  I'm looking to see if the server receives the transmits 
and then replies.

>  	RAL[0]         52411600
>  	RAH[0]         8000de50
> -	RAL[1]         00003333
> +	RAL[1]         005e0001
>  	RAH[1]         8000fb00
> -	RAL[2]         52ff3333
> -	RAH[2]         8000de50
> -	RAL[3]         00003333
> -	RAH[3]         80000100
> -	RAL[4]         005e0001
> +	RAL[2]         00003333
> +	RAH[2]         8000fb00
> +	RAL[3]         52ff3333
> +	RAH[3]         8000de50
> +	RAL[4]         00003333
>  	RAH[4]         80000100
> -	RAL[5]         00000000
> -	RAH[5]         00000000
> +	RAL[5]         005e0001
> +	RAH[5]         80000100

after resume, one multicast address is added and one is missing from the 
list of addresses the adapter will listen on.  I reordered but here are 
the diffs
before:
	RAL[5]         00000000
	RAH[5]         00000000
after
	RAL[5]         005e0001
	RAH[5]         8000fb00

I don't know which protocol added 01005e00fb as a multicast address only 
after suspend.

can you ifconfig eth0 promisc before doing suspend?  I'd be curious if 
that fixed it.

>  	RAL[6]         00000000
>  	RAH[6]         00000000
>  	RAL[7]         00000000
> @@ -390,7 +390,7 @@
>  	GSCL_2         00000000
>  	GSCL_3         00000000
>  	GSCL_4         00000000
> -	FACTPS         a1041046
> +	FACTPS         21041046

FACTPS bits are reserved in our manuals (but have to do with PCIe power state
changes), but I can't help but wonder if there isn't something with ASPM L0s or
L1 on your system (where we had trouble with that feature on your laptop) when
coming out of resume, therefore the lspci would show us the difference if there
was one.

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
