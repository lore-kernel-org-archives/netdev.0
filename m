From: Stefan Wenk <stefan.wenk@gmx.at>
Subject: Re: [Bugme-new] [Bug 8405] New: pppd does stops compresion with "Lost compression sync"
Date: Wed, 2 May 2007 18:59:55 +0200
Message-ID: <200705021859.55296.stefan.wenk@gmx.at>
References: <200704292001.l3TK1P6d000716@fire-2.osdl.org> <200705010927.52426.stefan.wenk@gmx.at> <1178054560.5883.87.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_LOMOGoeDAiSw6oO"
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: Richard Purdie <rpurdie@rpsys.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:43696 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1766788AbXEBRBc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 13:01:32 -0400
In-Reply-To: <1178054560.5883.87.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_LOMOGoeDAiSw6oO
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

> Having looked at the code a bit further, I have a theory that it was
> impossible to reach the zlib_inflateSyncPacket call ppp deflate needs.
> The patch below fixes that and also adds some debugging so if that isn't
> the problem, we might get some further clues as to what the problem
> is...
>
> Thanks for the patience :)
>
> Richard
>
> Index: linux/drivers/net/ppp_deflate.c
> ===================================================================
> --- linux.orig/drivers/net/ppp_deflate.c 2007-01-18 00:52:50.000000000
> +0000 +++ linux/drivers/net/ppp_deflate.c 2007-05-01 22:21:27.000000000
> +0100 @@ -488,6 +488,13 @@ int z_decompress(void *arg, unsigned cha
>   for (;;) {
>    r = zlib_inflate(&state->strm, Z_PACKET_FLUSH);
>    if (r != Z_OK) {
> +   printk(KERN_ERR "z_decompress%d: inflate returned %d (%s)"
> +    ",av in %d, av out %d, t in %ld, t out %ld, dp %d,"
> +    " of %d, is %d, os %d\n",
> +    state->unit, r, (state->strm.msg? state->strm.msg: ""),
> +    state->strm.avail_in, state->strm.avail_out,
> +    state->strm.total_in, state->strm.total_out,
> +    decode_proto, overflow, isize, osize);
>     if (state->debug)
>      printk(KERN_DEBUG "z_decompress%d: inflate returned %d (%s)\n",
>             state->unit, r, (state->strm.msg? state->strm.msg: ""));
> Index: linux/lib/zlib_inflate/inflate.c
> ===================================================================
> --- linux.orig/lib/zlib_inflate/inflate.c 2007-01-18 00:53:08.000000000
> +0000 +++ linux/lib/zlib_inflate/inflate.c 2007-05-01 22:03:53.000000000
> +0100 @@ -743,12 +743,14 @@ int zlib_inflate(z_streamp strm, int flu
>
>      strm->data_type = state->bits + (state->last ? 64 : 0) +
>                        (state->mode == TYPE ? 128 : 0);
> -    if (((in == 0 && out == 0) || flush == Z_FINISH) && ret == Z_OK)
> -        ret = Z_BUF_ERROR;
>
>      if (flush == Z_PACKET_FLUSH && ret == Z_OK &&
>              (strm->avail_out != 0 || strm->avail_in == 0))
>    return zlib_inflateSyncPacket(strm);
> +
> +    if (((in == 0 && out == 0) || flush == Z_FINISH) && ret == Z_OK)
> +        ret = Z_BUF_ERROR;
> +
>      return ret;
>  }

The situation now is similar as without any modifications. Instead of -5 
(Z_BUF_ERROR)
we get back -3 (Z_DATA_ERROR) from zlib_inflate. Here is the kernel log

kernel: PPP generic driver version 2.4.2
pppd[6101]: pppd 2.4.4 started by root, uid 0
pppd[6101]: Using interface ppp0
pppd[6101]: Connect: ppp0 <--> /dev/pts/8
pppd[6101]: kernel does not support PPP filtering
kernel: PPP BSD Compression module registered
kernel: PPP Deflate Compression module registered
pppd[6101]: Deflate (15) compression enabled
pppd[6101]: Cannot determine ethernet address for proxy ARP
pppd[6101]: local  IP address 192.168.3.2
pppd[6101]: remote IP address 192.168.3.1
kernel: z_decompress0: inflate returned -3 (),av in 0, av out 1, t in 1520, t 
out 3070, dp 0, of 1, is 644, os 1504
kernel: z_decompress0: inflate returned -3 ()
pppd[6101]: Lost compression sync: disabling compression
pppd[6101]: Terminating on signal 2
pppd[6101]: Child process pppd (charshunt) (pid 6131) terminated with signal 2
pppd[6101]: Modem hangup
pppd[6101]: Connect time 0.2 minutes.
pppd[6101]: Sent 2969 bytes, received 2774 bytes.
pppd[6101]: Connection terminated.
pppd[6101]: Exit.

Attached you find the corresponding pppdump file.

--Boundary-00=_LOMOGoeDAiSw6oO
Content-Type: application/octet-stream;
  name="selfhtml2.ppdump"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="selfhtml2.ppdump"

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
MjIiIHZsAgAIaW5rPSIjNzcCAAgyMjAwIiBhbA==

--Boundary-00=_LOMOGoeDAiSw6oO--
