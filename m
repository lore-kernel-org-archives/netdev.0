From: Vincent Li <vincent.mc.li@gmail.com>
Subject: [PATCH] Allow userspace code to use flag IFA_F_SECONDARY to specify an ip address to be primary or secondary ip on an interface
Date: Tue, 24 Sep 2013 11:11:21 -0700
Message-ID: <1380046281-6012-1-git-send-email-vincent.mc.li@gmail.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	Vincent Li <vincent.mc.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

the current behavior is when an IP is added to an interface, the primary
or secondary attributes is depending on the order of ip added to the interface
the first IP will be primary and second, third,... or alias IP will be secondary
if the IP subnet matches

this patch add the flexiblity to allow user to specify an argument 'primary' or 'secondary'
(use 'ip addr add ip/mask primary|secondary dev ethX ' from iproute2 for example) to specify
an IP address to be  primary or secondary.

the reason for this patch is that we have a multi blade cluster platform sharing 'floating management ip'
and also that each blade has its own management ip on the management interface, so whichever blade in the
cluster becomes primary blade, the 'floating mangaement ip' follows it, and we want any of our traffic
originated from the primary blade source from the 'floating management ip' for consistency. but in this
case, since the local blade management ip is always the primary ip on the mangaement interface and 'floating
management ip' is always secondary, kernel always choose the primary ip as source ip address. thus we would
like to add the flexibility in kernel to allow us to specify which ip to be primary or secondary.

Signed-off-by: Vincent Li <vincent.mc.li@gmail.com>
---
 net/ipv4/devinet.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index a1b5bcb..bfc702a 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -440,9 +440,11 @@ static int __inet_insert_ifa(struct in_ifaddr *ifa, struct nlmsghdr *nlh,
 		return 0;
 	}
 
-	ifa->ifa_flags &= ~IFA_F_SECONDARY;
 	last_primary = &in_dev->ifa_list;
 
+	if((*last_primary) == NULL)
+		ifa->ifa_flags &= ~IFA_F_SECONDARY;
+
 	for (ifap = &in_dev->ifa_list; (ifa1 = *ifap) != NULL;
 	     ifap = &ifa1->ifa_next) {
 		if (!(ifa1->ifa_flags & IFA_F_SECONDARY) &&
@@ -458,7 +460,10 @@ static int __inet_insert_ifa(struct in_ifaddr *ifa, struct nlmsghdr *nlh,
 				inet_free_ifa(ifa);
 				return -EINVAL;
 			}
-			ifa->ifa_flags |= IFA_F_SECONDARY;
+                        if (!(ifa->ifa_flags & IFA_F_SECONDARY))
+                                ifa1->ifa_flags |= IFA_F_SECONDARY;
+                        else
+                                ifa->ifa_flags |= IFA_F_SECONDARY;
 		}
 	}
 
-- 
1.7.9.5
