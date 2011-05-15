From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH 1/1] igmp: fix ip_mc_clear_src to not reset
 ip_mc_list->sf{mode,count}
Date: Sun, 15 May 2011 18:59:45 +0200
Message-ID: <20110515165945.GA20024@darkmag.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Marek <mmarek@suse.cz>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kbuild-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ip_mc_clear_src resets the imc->sfcount and imc->sfmode, without taking into
account the current number of sockets listening on that multicast struct, which
can lead to bogus routes for local listeners.

On NETDEV_DOWN/UP event, if there were 3 multicast listeners for that interface's
address, the imc->sfcount[MCAST_EXCLUDE] will be reset to 1. And after that a
listener socket destroys, multicast traffic will not be delivered to local
listeners because __mkroute_output drops the local flag for the route (by
checking ip_check_mc).

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 1fd3d9c..b14f371 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1775,9 +1775,6 @@ static void ip_mc_clear_src(struct ip_mc_list *pmc)
 		kfree(psf);
 	}
 	pmc->sources = NULL;
-	pmc->sfmode = MCAST_EXCLUDE;
-	pmc->sfcount[MCAST_INCLUDE] = 0;
-	pmc->sfcount[MCAST_EXCLUDE] = 1;
 }
 
 
