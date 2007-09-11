From: "Magnus Damm" <magnus.damm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] cfg80211: fix initialisation if built-in
Date: Tue, 11 Sep 2007 10:04:16 +0900
Message-ID: <aec7e5c30709101804p337084e9o63b5bcb4f007828@mail.gmail.com>
References: <1189424685.4506.63.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Rob Hussey" <robjhussey-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: "Johannes Berg" <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1189424685.4506.63.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 9/10/07, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> When cfg80211 is built into the kernel it needs to init earlier
> so that device registrations are run after it has initialised.
>
> Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>

Yep, I need this fix as well. Without it the ath5k driver built in
bombs out during module_init(). Something with kref and a struct
device pointing to an uninitialized ieee80211_class.

I need a similar fix for net/mac80211/rc80211_simple.c as well to get
ath5k working though, not sure why at the moment. There may be some
bug with request_module() not being called properly.
ieee80211_register_hw() calls ieee80211_init_rate_ctrl_alg() with NULL
as name which calls rate_control_alloc() with NULL which always seems
to fail when built in.

This hack works around that problem, not sure what the real fix is.

--- 0002/net/mac80211/rc80211_simple.c
+++ work/net/mac80211/rc80211_simple.c  2007-09-09 18:11:48.000000000 +0900
@@ -431,7 +431,8 @@ static void __exit rate_control_simple_e
 }


-module_init(rate_control_simple_init);
+//module_init(rate_control_simple_init);
+postcore_initcall(rate_control_simple_init);
 module_exit(rate_control_simple_exit);

 MODULE_DESCRIPTION("Simple rate control algorithm for ieee80211");

Thanks,

/ magnus
