From: jamal <hadi@cyberus.ca>
Subject: Re: dummy as IMQ replacement
Date: 02 Feb 2005 09:24:53 -0500
Message-ID: <1107354293.1105.85.camel@jzny.localdomain>
References: <20050131151532.GE31837@postel.suug.ch>
	 <1107186044.1076.11.camel@jzny.localdomain>
	 <20050131155929.GF31837@postel.suug.ch>
	 <1107189625.1076.77.camel@jzny.localdomain>
	 <20050131181553.GG31837@postel.suug.ch>
	 <1107202715.1075.559.camel@jzny.localdomain>
	 <20050131225328.GI31837@postel.suug.ch>
	 <1107259361.1095.584.camel@jzny.localdomain>
	 <20050201125147.GK31837@postel.suug.ch>
	 <1107263612.1095.598.camel@jzny.localdomain>
	 <20050201224436.GO31837@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050201224436.GO31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-02-01 at 17:44, Thomas Graf wrote:
> > Let the meta action do that. Just set the skb->tc_classid in my opinion;
> > recall we can change classid now ..
> 
> True, I don't really care but it's already quite confusing. The priority
> of the packet is described in viarous field depeding on which qdisc/cls
> being used, we have skb->priority with sch_prio, tc_index for dsmark
> and cls_tcindex and now tc_classid directly.  Some even use u32 to
> match on DSCP and set a nfmark.  I can already feel the perfect confusion
> once we open up access for rt_classid, realm and other routing fields.
> I'm always aiming for easy to understand solutions, this doesn't mean
> it to be simple. Why is nfmark so heavly used? Because it's damn simple
> to undertand, you can set and read it and that's it. The only thing one
> has to care about is to make sure that is actually gets set before it being
> read and to make sure all userspace apps read it in the same base ;->
> (This is basically one of the issue in usability, the lack of clearliness
> in what base number are read the displayed. Often they get displayed in
> hex without a 0x prefix but are read with strtol(...,0) resulting in
> a decimal reading if no prefix is specified)

So let me put it this way:
You cant avoid passing around metadata between the different blocks.
Whether the metadata is set by the admin or by some other block along
the packet path is way of life. 
All of the metadata defined and attached around skbs so far has a
standalone semantical meaning whic unfortunately cant just be hidden
from the user. Its the unfortunate consequence of giving someone a
weapon )they may shoot their toe off). 
As an example:
People have been setting flowid/classid for years via the classifiers
to stamp session a flow belongs to. All we are doing with
skb->tc_classid is giving more power to them. i.e before you get to the
queue given certain computation/state you may decide to belong to a
different session.
sfq as a matter of setting the hash is computing what flow you belong to
and thats why i suggested tc_classid (in this case not set by the admin,
rather by a smart stateful classifier).

> Long rant short statement, I'm pleading for a generic way to transfer
> such things between a classifier and a qdisc because it's simply
> easier to explain and use.
> ... eaction meta set tc_index ip_saddr_proto_hash
> ... qdisc sfq tcindex-hash

> where ip_saddr_proto_hash is not a variable but rather a special meta
> value calulated in the kernel.
> 

Let me see if i understood correctly: Instead of giving static values
(such as 0x10) you want to assign a variable(ip_saddr_proto_hash) which
is computed at runtime to tcindex? 
Thats a parallel issue though but indeed useful .

> > You can let the user define that via tc but have a default;
> > eg: 
> > tc dev eth0 add sfq ematch
> > tc dev eth0 set sfq pertub xxx
> > 
> > match u32 ...
> > ematch sfq
> > ematch meta classid 1:2 
> > eaction meta set tcindex 101
> > eaction meta set fwmark ..
> 
> I think we're on the same road or at least going into the same direction.
> However I'm not sure whether it's a good to have ematches return
> some values besides true/false. I'd rather like to see an eaction store
> it in the skb and the sfq catching it up again. Of course we can have the
> userspace part be configured within the sfq.

A classifier is allowed to select/set the class/flow/sessionID. 
The sfq hash result should at least set/map to the minor value of the
classid

cheers,
jamal
