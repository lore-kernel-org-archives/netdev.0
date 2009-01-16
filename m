From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: ixgbe: Replace LRO with GRO
Date: Fri, 16 Jan 2009 15:32:56 -0800
Message-ID: <9929d2390901161532j57528215mdb01f38be1bd4c7f@mail.gmail.com>
References: <20090113092625.GA28015@gondor.apana.org.au>
	 <20090113092828.GA28052@gondor.apana.org.au>
	 <20090114084412.GA17393@gondor.apana.org.au>
	 <20090115034619.GA28267@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Emil Tantilov <emil.s.tantilov@intel.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:14612 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758872AbZAPXc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 18:32:58 -0500
Received: by yw-out-2324.google.com with SMTP id 9so828635ywe.1
        for <netdev@vger.kernel.org>; Fri, 16 Jan 2009 15:32:57 -0800 (PST)
In-Reply-To: <20090115034619.GA28267@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 7:46 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Wed, Jan 14, 2009 at 07:44:12PM +1100, Herbert Xu wrote:
>>
>> ixgbe: Replace LRO with GRO
>
> I forgot to delete the Kconfig dependency, here is an updated
> version.
>
> ixgbe: Replace LRO with GRO
>
> This patch makes igb invoke the GRO hooks instead of LRO.  As
> GRO has a compatible external interface to LRO this is a very
> straightforward replacement.
>
> As GRO uses the napi structure to track the held packets, I've
> modified the code paths involved to pass that along.
>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>

Adding Emil to provide further testing details...

We are seeing data corruption with this patch applied.  When we
disable GRO the data corruption goes away.

We have this simple ftp test that does put/get and then compares
md5sum of the file. The file we get back is different then the one we
sent with GRO enabled.  The file is around 34MB. Note that we don't
always see the corruption with 30meg file, but it becomes more
apparent as we increase the size of the file.

If this helps - Emil did a diff off of a hexdump output between the
sent and received file. Looks like the receive was cut off at the end:

--- sent.dump	2009-01-16 11:48:50.000000000 -0800
+++ received.dump	2009-01-16 11:48:47.000000000 -0800
@@ -62714,43 +62714,5 @@
 00f4f90 0000 0000 ffff ffff 0000 0000 ffff ffff  00f4fa0 0000 0000
ffff ffff 0000 0000 ffff ffff  00f4fb0 0000 0000 ffff ffff 0000 0000
ffff ffff -00f4fc0 0000 0000 ffff ffff 0000 0000 ffff ffff -00f4fd0
0000 0000 ffff ffff 0000 0000 ffff ffff -00f4fe0 0000 0000 ffff ffff
0000 0000 ffff ffff -00f4ff0 0000 0000 ffff ffff 0000 0000 ffff ffff
-00f5000 0000 0000 ffff ffff 0000 0000 ffff ffff -00f5010 0000 0000
ffff ffff 0000 0000 ffff ffff -00f5020 0000 0000 ffff ffff 0000 0000
ffff ffff -00f5030 0000 0000 ffff ffff 0000 0000 ffff ffff -00f5040
0000 0000 ffff ffff 0000 0000 ffff ffff -00f5050 0000 0000 ffff ffff
0000 0000 ffff ffff -00f5060 0000 0000 ffff ffff 0000 0000 ffff ffff
-00f5070 0000 0000 ffff ffff 0000 0000 ffff ffff -00f5080 0000 0000
ffff ffff 0000 0000 ffff ffff -00f5090 0000 0000 ffff ffff 0000 0000
ffff ffff -00f50a0 0000 0000 ffff ffff 0000 0000 ffff ffff -00f50b0
0000 0000 ffff ffff 0000 0000 ffff ffff -00f50c0 0000 0000 ffff ffff
0000 0000 ffff ffff -00f50d0 0000 0000 ffff ffff 0000 0000 ffff ffff
-00f50e0 0000 0000 ffff ffff 0000 0000 ffff ffff -00f50f0 0000 0000
ffff ffff 0000 0000 ffff ffff -00f5100 0000 0000 ffff ffff 0000 0000
ffff ffff -00f5110 0000 0000 ffff ffff 0000 0000 ffff ffff -00f5120
0000 0000 ffff ffff 0000 0000 ffff ffff -00f5130 0000 0000 ffff ffff
0000 0000 ffff ffff -00f5140 0000 0000 ffff ffff 0000 0000 ffff ffff
-00f5150 0000 0000 ffff ffff 0000 0000 ffff ffff -00f5160 0000 0000
ffff ffff 0000 0000 ffff ffff -00f5170 0000 0000 ffff ffff 0000 0000
ffff ffff -00f5180 0000 0000 ffff ffff 0000 0000 ffff ffff -00f5190
0000 0000 ffff ffff 0000 0000 ffff ffff -00f51a0 0000 0000 ffff ffff
0000 0000 ffff ffff -00f51b0 0000 0000 ffff ffff 0000 0000 ffff ffff
-00f51c0 0000 0000 ffff ffff 0000 0000 ffff ffff -00f51d0 0000 0000
ffff ffff 0000 0000 ffff ffff -00f51e0 0000 0000 ffff ffff 0000 0000
ffff ffff -00f51f0 0000 0000 ffff ffff 0000 0000 ffff ffff -00f5200
0000 0000 ffff ffff 0000 0000 ffff ffff -00f5210 0000 0000 ffff ffff
0000 0000 ffff ffff -00f5220 0000 0000 ffff ffff 0000 0000 ffff ffff
-00f5230
+00f4fc0 0000 0000 ffff ffff
+00f4fc8

-- 
Cheers,
Jeff
