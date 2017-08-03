From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: [PATCH v4 net-next 04/13] bpf/verifier: more concise
 register state logs for constant var_off
Date: Thu, 3 Aug 2017 17:12:38 +0100
Message-ID: <695e6ddf-067a-b347-d9ef-283582ae6955@solarflare.com>
References: <22441d84-0a11-5c00-2d2a-25e7dbafa6c2@solarflare.com>
Reply-To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <22441d84-0a11-5c00-2d2a-25e7dbafa6c2-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
---
 kernel/bpf/verifier.c | 46 +++++++++++++++++++++++++++-------------------
 1 file changed, 27 insertions(+), 19 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index ca14f59..2924b01 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -234,25 +234,33 @@ static void print_verifier_state(struct bpf_verifier_state *state)
 				verbose(",ks=%d,vs=%d",
 					reg->map_ptr->key_size,
 					reg->map_ptr->value_size);
-			if (reg->smin_value != reg->umin_value &&
-			    reg->smin_value != S64_MIN)
-				verbose(",smin_value=%lld",
-					(long long)reg->smin_value);
-			if (reg->smax_value != reg->umax_value &&
-			    reg->smax_value != S64_MAX)
-				verbose(",smax_value=%lld",
-					(long long)reg->smax_value);
-			if (reg->umin_value != 0)
-				verbose(",umin_value=%llu",
-					(unsigned long long)reg->umin_value);
-			if (reg->umax_value != U64_MAX)
-				verbose(",umax_value=%llu",
-					(unsigned long long)reg->umax_value);
-			if (!tnum_is_unknown(reg->var_off)) {
-				char tn_buf[48];
-
-				tnum_strn(tn_buf, sizeof(tn_buf), reg->var_off);
-				verbose(",var_off=%s", tn_buf);
+			if (tnum_is_const(reg->var_off)) {
+				/* Typically an immediate SCALAR_VALUE, but
+				 * could be a pointer whose offset is too big
+				 * for reg->off
+				 */
+				verbose(",imm=%llx", reg->var_off.value);
+			} else {
+				if (reg->smin_value != reg->umin_value &&
+				    reg->smin_value != S64_MIN)
+					verbose(",smin_value=%lld",
+						(long long)reg->smin_value);
+				if (reg->smax_value != reg->umax_value &&
+				    reg->smax_value != S64_MAX)
+					verbose(",smax_value=%lld",
+						(long long)reg->smax_value);
+				if (reg->umin_value != 0)
+					verbose(",umin_value=%llu",
+						(unsigned long long)reg->umin_value);
+				if (reg->umax_value != U64_MAX)
+					verbose(",umax_value=%llu",
+						(unsigned long long)reg->umax_value);
+				if (!tnum_is_unknown(reg->var_off)) {
+					char tn_buf[48];
+
+					tnum_strn(tn_buf, sizeof(tn_buf), reg->var_off);
+					verbose(",var_off=%s", tn_buf);
+				}
 			}
 			verbose(")");
 		}
