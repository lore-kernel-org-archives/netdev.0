From: Patrick McHardy <kaber@trash.net>
Subject: Re: ipsec hang
Date: Wed, 24 Nov 2004 02:32:36 +0100
Message-ID: <41A3E4B4.8080401@trash.net>
References: <200411240134.50314@senat>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000507000605040608010207"
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261662AbUKXBcn@vger.kernel.org>
To: =?ISO-8859-15?Q?Marcin_Gibu=B3a?= <mg@iceni.pl>
In-Reply-To: <200411240134.50314@senat>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000507000605040608010207
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 8bit

Marcin Gibu³a wrote:

>Hi,
>today I tried to configure ipsec on my linux workstation (with openswan) and 
>it hanged just after the init had run /etc/rc.d/init.d/ipsec start. 
>It was on linux-2.6.10-rc1-bk20, so I upgraded to 2.6.10-rc2-mm3 but it didn't 
>make any difference. 
>
>The alt-sysrq-p shows the following call trace:
>xfrm_policy_insert
>xfrm_netlink_rcv
>netlink_data_ready
>netlink_sendmsg
>sock_aio_write
>do_sync_write
>sock_map_fd
>sys_select
>vfs_write
>system_call
>
>The full trace (with regs, etc) is available at 
>http://www.iceni.pl/marcin/lockup.jpg 
>
>.config attached. This hang is 100%-reproductible for me. I can attach 
>openswan config if needed.
>
This patch should fix it. The patch "Fix policy update bug when increasing
priority of last policy" broke this, when a policy with lower priority than
an existing policy is inserted xfrm_policy_insert loops forever.

Regards
Patrick


--------------000507000605040608010207
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/11/24 02:25:16+01:00 kaber@coreworks.de 
#   [XFRM]: Fix endless loop in xfrm_policy_insert
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/xfrm/xfrm_policy.c
#   2004/11/24 02:25:07+01:00 kaber@coreworks.de +1 -0
#   [XFRM]: Fix endless loop in xfrm_policy_insert
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
--- a/net/xfrm/xfrm_policy.c	2004-11-24 02:31:08 +01:00
+++ b/net/xfrm/xfrm_policy.c	2004-11-24 02:31:08 +01:00
@@ -353,6 +353,7 @@
 			newpos = p;
 		if (delpol)
 			break;
+		p = &pol->next;
 	}
 	if (newpos)
 		p = newpos;

--------------000507000605040608010207--
