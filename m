From: Patrick McHardy <kaber@trash.net>
Subject: Re: iptables breakage WAS(Re: dummy as IMQ replacement
Date: Fri, 25 Mar 2005 21:07:24 +0100
Message-ID: <42446F7C.3000907@trash.net>
References: <1107123123.8021.80.camel@jzny.localdomain>	 <423B7BCB.10400@dsl.pipex.com>	 <1111410890.1092.195.camel@jzny.localdomain>	 <423F41AD.3010902@dsl.pipex.com>	 <1111444869.1072.51.camel@jzny.localdomain>	 <423F71C2.8040802@dsl.pipex.com> <1111462263.1109.6.camel@jzny.localdomain>	 <42408998.5000202@dsl.pipex.com>	 <1111550254.1089.21.camel@jzny.localdomain>	 <4241C478.5030309@dsl.pipex.com>	 <1111607112.1072.48.camel@jzny.localdomain>	 <4241D764.2030306@dsl.pipex.com>	 <1111612042.1072.53.camel@jzny.localdomain>	 <4241F1D2.9050202@dsl.pipex.com>  <4241F7F0.2010403@dsl.pipex.com>	 <1111625608.1037.16.camel@jzny.localdomain> <424212F7.10106@dsl.pipex.com>	 <1111663947.1037.24.camel@jzny.localdomain>	 <1111665450.1037.27.camel@jzny.localdomain>	 <4242DFB5.9040802@dsl.pipex.com>	 <1111749220.1092.457.camel@jzny.localdomain>	 <1111754346.1092.480.camel@jzny.localdomain>  <42444A14.30
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050804000005080600090003"
Cc: Andy Furniss <andy.furniss@dsl.pipex.com>,
        Harald Welte <laforge@gnumonks.org>, Remus <rmocius@auste.elnet.lt>,
        netdev <netdev@oss.sgi.com>, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Andre Tomt <andre@tomt.net>, syrius.ml@no-log.org,
        Damion de Soto <damion@snapgear.com>
To: hadi@cyberus.ca
In-Reply-To: <42445FFE.6040408@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050804000005080600090003
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> tcf_dump_walker() doesn't save the number of skipped entries, but
> the last order dumped, so it could dump the same entries again
> and again when they exceed the room in the skb.

How about this patch? It fixes two problems:

- off-by-one while skipping entries: index is incremented before the
   comparison with s_i, so it will start dumping at entry s_i-1 instead
   of s_i
- problem described above. n_i doesn't include how many empty hash
   chains were skipped, so adding it to cb->args[0] is incorrect

Regards
Patrick

--------------050804000005080600090003
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

===== include/net/pkt_act.h 1.10 vs edited =====
--- 1.10/include/net/pkt_act.h	2005-01-10 22:54:01 +01:00
+++ edited/include/net/pkt_act.h	2005-03-25 20:58:28 +01:00
@@ -102,20 +102,21 @@
 		p = tcf_ht[tcf_hash(i)];
 
 		for (; p; p = p->next) {
-			index++;
-			if (index < s_i)
+			if (index < s_i) {
+				index++;
 				continue;
+			}
 			a->priv = p;
 			a->order = n_i;
 			r = (struct rtattr*) skb->tail;
 			RTA_PUT(skb, a->order, 0, NULL);
 			err = tcf_action_dump_1(skb, a, 0, 0);
 			if (0 > err) {
-				index--;
 				skb_trim(skb, (u8*)r - skb->data);
 				goto done;
 			}
 			r->rta_len = skb->tail - (u8*)r;
+			index++;
 			n_i++;
 			if (n_i >= TCA_ACT_MAX_PRIO) {
 				goto done;
@@ -124,8 +125,7 @@
 	}
 done:
 	read_unlock(&tcf_t_lock);
-	if (n_i)
-		cb->args[0] += n_i;
+	cb->args[0] = index;
 	return n_i;
 
 rtattr_failure:

--------------050804000005080600090003--
