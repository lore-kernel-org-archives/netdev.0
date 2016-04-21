From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] ipv4/fib: don't warn when primary address is missing if in_dev is dead
Date: Thu, 21 Apr 2016 22:23:31 +0200
Message-ID: <d6406682cc84a9de9a52bd31eaa6a372f3251f88.1461269273.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After commit fbd40ea0180a ("ipv4: Don't do expensive useless work
during inetdev destroy.") when deleting an interface,
fib_del_ifaddr() can be executed without any primary address
present on the dead interface.

The above is safe, but triggers some "bug: prim == NULL" warnings.

This commit avoids warning if the in_dev is dead

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/fib_frontend.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 8a9246d..63566ec 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -904,7 +904,11 @@ void fib_del_ifaddr(struct in_ifaddr *ifa, struct in_ifaddr *iprim)
 	if (ifa->ifa_flags & IFA_F_SECONDARY) {
 		prim = inet_ifa_byprefix(in_dev, any, ifa->ifa_mask);
 		if (!prim) {
-			pr_warn("%s: bug: prim == NULL\n", __func__);
+			/* if the device has been deleted, we don't perform
+			 * address promotion
+			 */
+			if (!in_dev->dead)
+				pr_warn("%s: bug: prim == NULL\n", __func__);
 			return;
 		}
 		if (iprim && iprim != prim) {
-- 
1.8.3.1
