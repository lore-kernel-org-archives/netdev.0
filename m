From: Thomas Graf <tgraf@suug.ch>
Subject: Re: dummy as IMQ replacement
Date: Tue, 1 Feb 2005 23:44:36 +0100
Message-ID: <20050201224436.GO31837@postel.suug.ch>
References: <20050131151532.GE31837@postel.suug.ch> <1107186044.1076.11.camel@jzny.localdomain> <20050131155929.GF31837@postel.suug.ch> <1107189625.1076.77.camel@jzny.localdomain> <20050131181553.GG31837@postel.suug.ch> <1107202715.1075.559.camel@jzny.localdomain> <20050131225328.GI31837@postel.suug.ch> <1107259361.1095.584.camel@jzny.localdomain> <20050201125147.GK31837@postel.suug.ch> <1107263612.1095.598.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1107263612.1095.598.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Let the meta action do that. Just set the skb->tc_classid in my opinion;
> recall we can change classid now ..

True, I don't really care but it's already quite confusing. The priority
of the packet is described in viarous field depeding on which qdisc/cls
being used, we have skb->priority with sch_prio, tc_index for dsmark
and cls_tcindex and now tc_classid directly.  Some even use u32 to
match on DSCP and set a nfmark.  I can already feel the perfect confusion
once we open up access for rt_classid, realm and other routing fields.
I'm always aiming for easy to understand solutions, this doesn't mean
it to be simple. Why is nfmark so heavly used? Because it's damn simple
to undertand, you can set and read it and that's it. The only thing one
has to care about is to make sure that is actually gets set before it being
read and to make sure all userspace apps read it in the same base ;->
(This is basically one of the issue in usability, the lack of clearliness
in what base number are read the displayed. Often they get displayed in
hex without a 0x prefix but are read with strtol(...,0) resulting in
a decimal reading if no prefix is specified)

Long rant short statement, I'm pleading for a generic way to transfer
such things between a classifier and a qdisc because it's simply
easier to explain and use.

... eaction meta set tc_index ip_saddr_proto_hash
... qdisc sfq tcindex-hash

where ip_saddr_proto_hash is not a variable but rather a special meta
value calulated in the kernel.

> You can let the user define that via tc but have a default;
> eg: 
> tc dev eth0 add sfq ematch
> tc dev eth0 set sfq pertub xxx
> 
> match u32 ...
> ematch sfq
> ematch meta classid 1:2 
> eaction meta set tcindex 101
> eaction meta set fwmark ..

I think we're on the same road or at least going into the same direction.
However I'm not sure whether it's a good to have ematches return
some values besides true/false. I'd rather like to see an eaction store
it in the skb and the sfq catching it up again. Of course we can have the
userspace part be configured within the sfq.
