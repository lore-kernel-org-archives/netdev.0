From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net/8021q/vlan_dev.c - Use print_mac
Date: Mon, 18 Feb 2008 16:50:36 -0800 (PST)
Message-ID: <20080218.165036.218650084.davem@davemloft.net>
References: <20080218.125525.192686382.davem@davemloft.net>
	<47B9F5E7.3020905@trash.net>
	<20080218.164305.67586867.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, bruno-L9ZBdB2wSWtl57MIdRCFDg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080218.164305.67586867.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Date: Mon, 18 Feb 2008 16:43:05 -0800 (PST)

> I think we can fix this easily by using __attribute_const_
> on the print_mac() declaration.  Let me play with that.

Actually it seems the 'pure' attribute is more important
here.  Although it's not semantically a perfect match,
what we need to tell the compiler is basically that:

1) the return value depends upon the inputs
2) if the input is not used, it's safe to avoid the call

and 'pure' accomplishes that without any unwanted side-effects.

I think this will not result in any unwanted over-optimization.
Because if the inputs change in any way GCC has to emit the
call.

Any objections?

commit 8f789c48448aed74fe1c07af76de8f04adacec7d
Author: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Date:   Mon Feb 18 16:50:22 2008 -0800

    [NET]: Elminate spurious print_mac() calls.
    
    Patrick McHardy notes that print_mac() can get invoked
    even if the result it unused (f.e. as an argument to
    pr_debug() when DEBUG is not defined).
    
    Mark this function as "__pure" to eliminate this problem.
    
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 7a1e011..42dc6a3 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -129,7 +129,7 @@ extern ssize_t sysfs_format_mac(char *buf, const unsigned char *addr, int len);
 /*
  *	Display a 6 byte device address (MAC) in a readable format.
  */
-extern char *print_mac(char *buf, const unsigned char *addr);
+extern __pure char *print_mac(char *buf, const unsigned char *addr);
 #define MAC_BUF_SIZE	18
 #define DECLARE_MAC_BUF(var) char var[MAC_BUF_SIZE] __maybe_unused
 
