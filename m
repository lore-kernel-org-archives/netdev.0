From: jamal <hadi@cyberus.ca>
Subject: Re: iptables breakage WAS(Re: dummy as IMQ replacement
Date: 25 Mar 2005 15:31:45 -0500
Message-ID: <1111782705.1091.644.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <423B7BCB.10400@dsl.pipex.com> <1111410890.1092.195.camel@jzny.localdomain>
	 <423F41AD.3010902@dsl.pipex.com>
	 <1111444869.1072.51.camel@jzny.localdomain>
	 <423F71C2.8040802@dsl.pipex.com> <1111462263.1109.6.camel@jzny.localdomain>
	 <42408998.5000202@dsl.pipex.com>
	 <1111550254.1089.21.camel@jzny.localdomain>
	 <4241C478.5030309@dsl.pipex.com>
	 <1111607112.1072.48.camel@jzny.localdomain>
	 <4241D764.2030306@dsl.pipex.com>
	 <1111612042.1072.53.camel@jzny.localdomain>
	 <4241F1D2.9050202@dsl.pipex.com>  <4241F7F0.2010403@dsl.pipex.com>
	 <1111625608.1037.16.camel@jzny.localdomain> <424212F7.10106@dsl.pipex.com>
	 <1111663947.1037.24.camel@jzny.localdomain>
	 <1111665450.1037.27.camel@jzny.localdomain>
	 <4242DFB5.9040802@dsl.pipex.com>
	 <1111749220.1092.457.camel@jzny.localdomain>
	 <1111754346.1092.480.camel@jzny.localdomai
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andy Furniss <andy.furniss@dsl.pipex.com>,
        Harald Welte <laforge@gnumonks.org>, Remus <rmocius@auste.elnet.lt>,
        netdev <netdev@oss.sgi.com>, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Andre Tomt <andre@tomt.net>, syrius.ml@no-log.org,
        Damion de Soto <damion@snapgear.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <42446F7C.3000907@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


>From the outset this looks fine. What would be a good test case?
Something that will ensure we go beyond 4K(NLMSG_GOODSIZE) for a dump?

cheers,
jamal

On Fri, 2005-03-25 at 15:07, Patrick McHardy wrote:
> Patrick McHardy wrote:
> > tcf_dump_walker() doesn't save the number of skipped entries, but
> > the last order dumped, so it could dump the same entries again
> > and again when they exceed the room in the skb.
> 
> How about this patch? It fixes two problems:
> 
> - off-by-one while skipping entries: index is incremented before the
>    comparison with s_i, so it will start dumping at entry s_i-1 instead
>    of s_i
> - problem described above. n_i doesn't include how many empty hash
>    chains were skipped, so adding it to cb->args[0] is incorrect
> 
> Regards
> Patrick
> 
> ______________________________________________________________________
> 
> ===== include/net/pkt_act.h 1.10 vs edited =====
> --- 1.10/include/net/pkt_act.h	2005-01-10 22:54:01 +01:00
> +++ edited/include/net/pkt_act.h	2005-03-25 20:58:28 +01:00
> @@ -102,20 +102,21 @@
>  		p = tcf_ht[tcf_hash(i)];
>  
>  		for (; p; p = p->next) {
> -			index++;
> -			if (index < s_i)
> +			if (index < s_i) {
> +				index++;
>  				continue;
> +			}
>  			a->priv = p;
>  			a->order = n_i;
>  			r = (struct rtattr*) skb->tail;
>  			RTA_PUT(skb, a->order, 0, NULL);
>  			err = tcf_action_dump_1(skb, a, 0, 0);
>  			if (0 > err) {
> -				index--;
>  				skb_trim(skb, (u8*)r - skb->data);
>  				goto done;
>  			}
>  			r->rta_len = skb->tail - (u8*)r;
> +			index++;
>  			n_i++;
>  			if (n_i >= TCA_ACT_MAX_PRIO) {
>  				goto done;
> @@ -124,8 +125,7 @@
>  	}
>  done:
>  	read_unlock(&tcf_t_lock);
> -	if (n_i)
> -		cb->args[0] += n_i;
> +	cb->args[0] = index;
>  	return n_i;
>  
>  rtattr_failure:
