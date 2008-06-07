From: Patrick McHardy <kaber@trash.net>
Subject: Re: Oops in nf_nat_core.c:find_appropriate_src(), kernel 2.6.25.4
Date: Sat, 07 Jun 2008 17:00:06 +0200
Message-ID: <484AA276.9090407@trash.net>
References: <484A9E75.8000601@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080708080501090002050501"
Cc: Netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <484A9E75.8000601@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080708080501090002050501
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Chuck Ebbert wrote:
> Reported at https://bugzilla.redhat.com/show_bug.cgi?id=449315
> 
> In find_appropriate_src():
> 
>         hlist_for_each_entry_rcu(nat, n, &bysource[h], bysource) {
>                 ct = nat->ct;
>                 if (same_src(ct, tuple)) {
> 
> Dereference of ct in same_src() causes the oops. This only seems to
> happen on heavily loaded firewall machines. Kernel 2.6.24.7 works.
> 
> The reporter identifies commit 4d354c5782dc352cec187845d17eedc2c2bfcf67
> ("[NETFILTER]: nf_nat: use RCU for bysource hash") as a possible cause
> of the problem.

We have a similar looking report, but that one also affects 2.6.24:

http://bugzilla.kernel.org/show_bug.cgi?id=10875

Anyways, does this patch help? When reallocating storage
for a conntrack, it is replaced in the list before assigning
the nat->ct pointer.


--------------080708080501090002050501
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index 0457859..945da60 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -570,8 +570,8 @@ static void nf_nat_move_storage(void *new, void *old)
 		return;
 
 	spin_lock_bh(&nf_nat_lock);
-	hlist_replace_rcu(&old_nat->bysource, &new_nat->bysource);
 	new_nat->ct = ct;
+	hlist_replace_rcu(&old_nat->bysource, &new_nat->bysource);
 	spin_unlock_bh(&nf_nat_lock);
 }
 

--------------080708080501090002050501--
