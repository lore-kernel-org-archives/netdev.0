From: Jonathan McDowell <noodles@earth.li>
Subject: [PATCH] Fix logic error in rfkill_check_duplicity
Date: Thu, 30 Oct 2008 14:44:09 +0000
Message-ID: <20081030144409.GJ3162@earth.li>
References: <20081029164006.GH3162@earth.li> <1225309212.3068.44.camel@achroite> <20081030102746.GI3162@earth.li>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from the.earth.li ([217.147.81.2]:59195 "EHLO the.earth.li"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754279AbYJ3OoK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2008 10:44:10 -0400
Content-Disposition: inline
In-Reply-To: <20081030102746.GI3162@earth.li>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 30, 2008 at 10:27:46AM +0000, Jonathan McDowell wrote:
 
> I'll have a prod at why the [hso] rfkill stuff isn't working next

Ok, I believe this is due to the addition of rfkill_check_duplicity in
rfkill and the fact that test_bit actually returns a negative value
rather than the postive one expected (which is of course equally true).
So when the second WLAN device (the hso device, with the EEE PC WLAN
being the first) comes along rfkill_check_duplicity returns a negative
value and so rfkill_register returns an error. Patch below fixes this
for me.

The hso driver should probably be claiming to be a WWAN device as well,
given that it's GSM/HSDPA rather than 802.11.

Signed-Off-By: Jonathan McDowell <noodles@earth.li>

-----
diff --git a/net/rfkill/rfkill.c b/net/rfkill/rfkill.c
index f949a48..1ba35a7 100644
--- a/net/rfkill/rfkill.c
+++ b/net/rfkill/rfkill.c
@@ -603,7 +603,7 @@ static int rfkill_check_duplicity(const struct rfkill *rfkil
        }
 
        /* 0: first switch of its kind */
-       return test_bit(rfkill->type, seen);
+       return (test_bit(rfkill->type, seen)) ? 1 : 0;
 }
 
 static int rfkill_add_switch(struct rfkill *rfkill)
-----

J.

-- 
/-\                             |  Shall I call the United Nations?
|@/  Debian GNU/Linux Developer |
\-                              |
