From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [REGRESSION][PATCH V4 3/3] bpf jit: Let the powerpc jit handle
 negative offsets
Date: Mon, 30 Apr 2012 14:11:28 +1000
Message-ID: <1335759088.20866.32.camel@pasglop>
References: <4F75CA89.4010709@googlemail.com>
	 <4F75D2A5.7060407@googlemail.com>
	 <20120403.180302.342779808900865443.davem@davemloft.net>
	 <1333491102.3040.12.camel@pasglop> <1335753820.20866.27.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kaffeemonster@googlemail.com, eric.dumazet@gmail.com,
	matt@ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1335753820.20866.27.camel@pasglop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-04-30 at 12:43 +1000, Benjamin Herrenschmidt wrote:

> > Matt's having a look at powerpc
> 
> Ok, he hasn't so I'll dig a bit.
> 
> No obvious wrongness (but I'm not very familiar with bpf), though I do
> have a comment: sk_negative_common() and bpf_slow_path_common() should
> be made one and single macro which takes the fallback function as an
> argument.

Ok, with the compile fix below it seems to work for me:

(Feel free to fold that into the original patch)

diff --git a/arch/powerpc/net/bpf_jit.h b/arch/powerpc/net/bpf_jit.h
index af1ab5e..5c3cf2d 100644
--- a/arch/powerpc/net/bpf_jit.h
+++ b/arch/powerpc/net/bpf_jit.h
@@ -48,7 +48,13 @@
 /*
  * Assembly helpers from arch/powerpc/net/bpf_jit.S:
  */
-extern u8 sk_load_word[], sk_load_half[], sk_load_byte[], sk_load_byte_msh[];
+#define DECLARE_LOAD_FUNC(func)	\
+	extern u8 func[], func##_negative_offset[], func##_positive_offset[]
+
+DECLARE_LOAD_FUNC(sk_load_word);
+DECLARE_LOAD_FUNC(sk_load_half);
+DECLARE_LOAD_FUNC(sk_load_byte);
+DECLARE_LOAD_FUNC(sk_load_byte_msh);
 
 #define FUNCTION_DESCR_SIZE	24
 
Cheers,
Ben.
