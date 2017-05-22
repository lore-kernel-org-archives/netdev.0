From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] kernel: bpf: remove dead code
Date: Mon, 22 May 2017 16:52:24 +0200
Message-ID: <5922FB28.5070303@iogearbox.net>
References: <20170522140746.GA10113@embeddedgus> <20170522.103800.1354089494827582585.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, garsilva@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170522.103800.1354089494827582585.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/22/2017 04:38 PM, David Miller wrote:
> From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
> Date: Mon, 22 May 2017 09:07:46 -0500
>
>> Execution cannot reach NET_IP_ALIGN inside the following statement:
>> ip_align = strict ? 2 : NET_IP_ALIGN
>>
>> Addresses-Coverity-ID: 1409762
>> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
>> ---
>> NOTE: variable ip_align could also be removed and use value 2 directly.
>
> Incorrect.
>
> Some platforms define NET_IP_ALIGN to zero, so the code must remain
> as is.

In the check_pkt_ptr_alignment(), when !strict you would already
return earlier from that function.

So, above test in ip_align will always give 2, meaning technically
the patch is correct, although hard-coded value less clean.

Perhaps something like the below to keep intentions more clear (and
it will get resolved during compile time anyway ...):

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index a098d95..3cf1d60 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2297,8 +2297,10 @@ static inline int pskb_network_may_pull(struct sk_buff *skb, unsigned int len)
   * Since this trade off varies between architectures, we allow NET_IP_ALIGN
   * to be overridden.
   */
+#define NET_IP_ALIGN_DEFAULT	2
+
  #ifndef NET_IP_ALIGN
-#define NET_IP_ALIGN	2
+#define NET_IP_ALIGN	NET_IP_ALIGN_DEFAULT
  #endif

  /*
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 1eddb71..61f6aaa 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -812,7 +812,7 @@ static int check_pkt_ptr_alignment(const struct bpf_reg_state *reg,
  	 * we force this to 2 which is universally what architectures use
  	 * when they don't set CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS.
  	 */
-	ip_align = strict ? 2 : NET_IP_ALIGN;
+	ip_align = NET_IP_ALIGN ? : NET_IP_ALIGN_DEFAULT;
  	if ((ip_align + reg_off + off) % size != 0) {
  		verbose("misaligned packet access off %d+%d+%d size %d\n",
  			ip_align, reg_off, off, size);
