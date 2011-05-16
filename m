From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V5 2/6 net-next] netdevice.h: Add zero-copy flag in
 netdevice
Date: Tue, 17 May 2011 00:14:59 +0300
Message-ID: <20110516211459.GE18148@redhat.com>
References: <1305574128.3456.23.camel@localhost.localdomain>
 <1305574518.2885.25.camel@bwh-desktop>
 <1305574680.3456.33.camel@localhost.localdomain>
 <1305575253.2885.28.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shirley Ma <mashirle@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1305575253.2885.28.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 16, 2011 at 08:47:33PM +0100, Ben Hutchings wrote:
> On Mon, 2011-05-16 at 12:38 -0700, Shirley Ma wrote:
> > On Mon, 2011-05-16 at 20:35 +0100, Ben Hutchings wrote:
> > > Sorry, bit 31 is taken.  You get the job of turning features into a
> > > wider bitmap.
> > 
> > :) will do it.
> 
> Bear in mind that feature masks are manipulated in many different
> places.  This is not a simple task.
> 
> See previous discussion at:
> http://thread.gmane.org/gmane.linux.network/193284
> and especially:
> http://thread.gmane.org/gmane.linux.network/193284/focus=193332
> 
> Ben.


IIUC, what is suggested above is something like:

typedef struct net_features {
} net_features_t;

and then

   void netdev_set_feature(net_features_t *net_features, int feature);
   void netdev_clear_feature(net_features_t *net_features, int feature);
   bool netdev_test_feature(net_features_t *net_features, int feature);


I think this might be the easiest way as compiler will catch any direct uses.
It can then be split up nicely.

It looks a bit different from what Dave suggested but I think it's
close enough?

we could also have wrappers that set/clear/test many features to replace
uses of A|B|C that are pretty common.

   static inline void netdev_set_features(net_features_t *net_features, int nfeatures, int *features)
   {
	int i;
	for (i = 0; i < nfeatures; ++i)
		netdev_set_feature(net_features, features[i]);
   }
   void netdev_clear_features(net_features_t *net_features, int nfeatures, int *features)
   {
	int i;
	for (i = 0; i < nfeatures; ++i)
		netdev_clear_feature(net_features, features[i]);
   }
   bool netdev_test_features(net_features_t *net_features, int nfeatures, int *features)
   {
	int i;
	for (i = 0; i < nfeatures; ++i)
		if (netdev_test_feature(net_features, features[i]))
			return true;
	return false;
   }

and possibly macros that get arrays of constants:

#define NETDEV_SET_FEATURES(net_features, feature_array) do { \
	int __NETDEV_SET_FEATURES_F[] = feature_array;
	netdev_set_feature((net_features), \
		ARRAY_SIZE(__NETDEV_SET_FEATURES_F), __NETDEV_SET_FEATURES_F);
} while (0)

etc.

> -- 
> Ben Hutchings, Senior Software Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
