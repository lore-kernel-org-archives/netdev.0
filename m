From: Stefano Babic <stefano.babic@babic.homelinux.org>
Subject: Re: [7/8,RFC] CAIF Protocol Stack
Date: Mon, 05 Oct 2009 18:22:09 +0200
Message-ID: <4ACA1D31.6000008@babic.homelinux.org>
References: <1253727096-10413-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Kim.xx.Lilliestierna@ericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout26.attiva.biz ([85.37.16.27]:46823 "EHLO
	smtpout26.attiva.biz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753912AbZJEQWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 12:22:51 -0400
In-Reply-To: <1253727096-10413-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sjur.brandeland@stericsson.com wrote:
> From: Kim Lilliestierna <Kim.xx.Lilliestierna@ericsson.com>
> 
> Signed-off-by: sjur.brandeland@stericsson.com

Hi Sjur,

> +A configuration tool chardevconfig exist in order to simplify
> +creation of CAIF Channels (typically used from init scripts).
> +E.g:
> +
> +   $chardevconfig /dev/caifconfig -
> +   CREATE TYPE=AT NAME=chnlat1 DEVTYPE=CHAR ^D

It seems that this command requires additional parameters as PRIO and
PHYPREF, else a "parse error" is reported by the tool.

> +GenCaif is a generic CAIF protocol implementation. It implements the CAIF
> +protocol as specified in "CAIF Protocol Specification" (155 19-CRH 109 913).

Is this one an internal document or was it published and is available
for reading ?

> diff --git a/Documentation/CAIF/README b/Documentation/CAIF/README
> new file mode 100644
> index 0000000..aa04150
> --- /dev/null
> +++ b/Documentation/CAIF/README
> @@ -0,0 +1,60 @@
> +copyright (C) ST-Ericsson AB 2009
> +Author: Sjur Brendeland/ sjur.brandeland@stericsson.com
> +        Kim Lilliestierna Kim.xx.Lilliestierna@ericsson.com
> +License terms: GNU General Public License (GPL), version 2.
> +
> +=== Start ===
> +Copy the .ko files onto the board, and do insmod:
> +
> +insmod caif.ko
> +insmod phyif_msl.ko

Is phyif_msl.ko obsolete ? There is no track of the corresponding source
file.

> +=== Preparing the setup.===
> +
> +Make sure that the kernel is built with module support.
> +
> +There are some things that need to be
> +tweaked to get the host TTY correctly setup to talk to the modem.
> +Since the CAIF stack is running in the kernel and we want to use the existing
> +TTY we are installing our physical serial driver as a line discipline above
> +the TTY device.

I wanted to test your patches and I tried to follow your description,
but I have some problems to connect the tty-layer with the physical uart
linux driver.
I use a different architecture - ARM (ARM9) based and I applied your
patches on a 2.6.29 kernel. I agree, I should apply them on the top of
2.6.31 as you tested, but it seems I have a configuration problem not
related to the kernel version.
I can see that CAIF wants to try to enumerate the devices
(cfctrl_enum_req is called) and then the phyif_ser module is called
(ser_phy_tx, as supposed). But then the systems hangs in the write loop
and the uart transmit function of the linux serial driver is never called.

To setup the system, if I really understood well, I followed the steps:

$ modprobe caif
$ modprobe phyif_ser
$ echo 6 > /sys/class/caif/dbg_lvl
$ ./ldiscd
caifdev_phy_register: phy:bf00fb68 id:1
caifdev_phy_register: bf00fb68 ID 1 == 1
$ modprobe chnl_chr
<caif_chrinit_module:1142, TRACE>
Compiled:Oct  5 2009:14:08:17
-bash-3.2# ./chardevconfig /dev/caifconfig -
CREATE TYPE=AT NAME=chnlat10 DEVTYPE=CHAR PHYPREF=LAT PRIO=HI
caifdev_open: Entered
caifdev_ioctl: Entered
<print_device_list:664, TRACE> List of devices:
<print_device_list:674, TRACE> list is empty
<chrdev_create:1005, TRACE> [chrdev_create:1005] dev=c3ab4800
<chrdev_create:1051, TRACE> [chrdev_create:1051] pktf=c3ab495c
<chrdev_create:1053, TRACE> [chrdev_create:1053] cfpkt_create_xmit=bf005bf4
<chrdev_create:1061, TRACE> dev: Registered dev with name=chnlat10
minor=52, dev=c3a65180
<print_device_list:664, TRACE> List of devices:
<print_device_list:670, TRACE> i = 0, minor= 52, name = chnlat10, open = 0
caifdev_release: Entered
Create device: name = chnlat10, major = 10, minor = 52

So it seems the device is correctly created.

Then I tried:
 echo -e "AT\r\n" > /dev/chnlat10
<print_device_list:664, TRACE> List of devices:
<print_device_list:670, TRACE> i = 0, minor= 52, name = chnlat10, open = 0
<find_device:627, TRACE> [find_device:627] start looping
<find_device:632, TRACE> [find_device:632] check 52,52, chnlat10, <NULL>
<find_device:646, TRACE> [find_device:646] match 52, <NULL>
<caif_chropen:721, TRACE> [caif_chropen:721] dev=c3ab4800

and the system hangs. I could find after some instrumentation that the
system hangs in the ser_phy_tx function. This is not a surprise, because
the Uart TX function is never called. Have I missed something ?

Best regards,
Stefano Babic

-- 
stefano <stefano.babic@babic.homelinux.org>
GPG Key: 0x55814DDE
Fingerprint 4E85 2A66 4CBA 497A 2A7B D3BF 5973 F216 5581 4DDE
