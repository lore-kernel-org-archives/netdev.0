From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] kernel: bpf: remove dead code
Date: Mon, 22 May 2017 12:27:42 -0400 (EDT)
Message-ID: <20170522.122742.1326733219925627993.davem@davemloft.net>
References: <20170522140746.GA10113@embeddedgus>
        <20170522.103800.1354089494827582585.davem@davemloft.net>
        <5922FB28.5070303@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: garsilva@embeddedor.com, ast@kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5922FB28.5070303@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon, 22 May 2017 16:52:24 +0200

> On 05/22/2017 04:38 PM, David Miller wrote:
>> From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
>> Date: Mon, 22 May 2017 09:07:46 -0500
>>
>>> Execution cannot reach NET_IP_ALIGN inside the following statement:
>>> ip_align = strict ? 2 : NET_IP_ALIGN
>>>
>>> Addresses-Coverity-ID: 1409762
>>> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
>>> ---
>>> NOTE: variable ip_align could also be removed and use value 2
>>> directly.
>>
>> Incorrect.
>>
>> Some platforms define NET_IP_ALIGN to zero, so the code must remain
>> as is.
> 
> In the check_pkt_ptr_alignment(), when !strict you would already
> return earlier from that function.
> 
> So, above test in ip_align will always give 2, meaning technically
> the patch is correct, although hard-coded value less clean.
> 
> Perhaps something like the below to keep intentions more clear (and
> it will get resolved during compile time anyway ...):

Ok I understand the issue now.  Thanks for explaining.

I guess a hard-coded value of 2 and an adjusted comment above the
assignment of ip_align is the way to go.

I'll push the following, thanks everyone:

====================
net: Make IP alignment calulations clearer.

The assignmnet:

	ip_align = strict ? 2 : NET_IP_ALIGN;

in compare_pkt_ptr_alignment() trips up Coverity because we can only
get to this code when strict is true, therefore ip_align will always
be 2 regardless of NET_IP_ALIGN's value.

So just assign directly to '2' and explain the situation in the
comment above.

Reported-by: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 kernel/bpf/verifier.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 1eddb71..c72cd41 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -808,11 +808,15 @@ static int check_pkt_ptr_alignment(const struct bpf_reg_state *reg,
 		reg_off += reg->aux_off;
 	}
 
-	/* skb->data is NET_IP_ALIGN-ed, but for strict alignment checking
-	 * we force this to 2 which is universally what architectures use
-	 * when they don't set CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS.
+	/* For platforms that do not have a Kconfig enabling
+	 * CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS the value of
+	 * NET_IP_ALIGN is universally set to '2'.  And on platforms
+	 * that do set CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS, we get
+	 * to this code only in strict mode where we want to emulate
+	 * the NET_IP_ALIGN==2 checking.  Therefore use an
+	 * unconditional IP align value of '2'.
 	 */
-	ip_align = strict ? 2 : NET_IP_ALIGN;
+	ip_align = 2;
 	if ((ip_align + reg_off + off) % size != 0) {
 		verbose("misaligned packet access off %d+%d+%d size %d\n",
 			ip_align, reg_off, off, size);
-- 
2.4.11
