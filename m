From: Thomas Graf <tgraf@suug.ch>
Subject: Re: dummy as IMQ replacement
Date: Wed, 2 Feb 2005 16:40:41 +0100
Message-ID: <20050202154041.GQ31837@postel.suug.ch>
References: <20050131155929.GF31837@postel.suug.ch> <1107189625.1076.77.camel@jzny.localdomain> <20050131181553.GG31837@postel.suug.ch> <1107202715.1075.559.camel@jzny.localdomain> <20050131225328.GI31837@postel.suug.ch> <1107259361.1095.584.camel@jzny.localdomain> <20050201125147.GK31837@postel.suug.ch> <1107263612.1095.598.camel@jzny.localdomain> <20050201224436.GO31837@postel.suug.ch> <1107354293.1105.85.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1107354293.1105.85.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

First of all, sorry for the massive amount of typos in my last post.
I could barely see anything due to the sun shining onto my display.

> You cant avoid passing around metadata between the different blocks.
> Whether the metadata is set by the admin or by some other block along
> the packet path is way of life. 

Agreed.

> All of the metadata defined and attached around skbs so far has a
> standalone semantical meaning whic unfortunately cant just be hidden
> from the user. Its the unfortunate consequence of giving someone a
> weapon )they may shoot their toe off). 

Agreed, I'm just trying avoid further confusion. I think my country
has one of highest if not the higest density of fully automatic
assault weapons (because everyone liable to miltary service needs
to have one at home), everyone owning one is forced to practice once
a year and shooting is a common sport.  OTOH, we have one of the lowest
crime rates. Why's that?  Because almost everyone is well educated
in terms of weapon saftey, so I think this should be our way as well.
So yes, we can definitely add more complexity but we should try to make
it easy to understand and use.

> sfq as a matter of setting the hash is computing what flow you belong to
> and thats why i suggested tc_classid (in this case not set by the admin,
> rather by a smart stateful classifier).

If the value for tc_classid is directly set by the user then I agree.
What I want to avoid is having hidden uses of parameters which can also
be modified by the user. It results in a backward compatibility hell
later on because we can't just add another use for it without possibily
breaking scripts.

> Let me see if i understood correctly: Instead of giving static values
> (such as 0x10) you want to assign a variable(ip_saddr_proto_hash) which
> is computed at runtime to tcindex? 
> Thats a parallel issue though but indeed useful .

OK, so basically we weren't talking of exactly the same thing. In a
user setting only context your argumentation makes sense. Let me follow
on this thought a little further, what I basically want is a generic
way to influence various qdiscs, be it a hashing index for sfq, a
priority value for priority band based qdiscs, etc.

tc_classid isn't a bad choice but it gets complex once we want a
classful qdiscs to be able to use this input parameter.

Summarizing what we currently have:
  tc_index: May contain a dscp value if dsmark is told to fetch the dscp
            field, the minor part of priority if dsmark is told to map
            priority values via handle values, or the minor part of the
            classid in a classifier result via ingress classification or
            a classifier attached to a dsmark. cls_tcindex, gred, and
            meta ematch use it as input value.

  nf_mark:  cls_fw map to classids, meta ematch may read it, meta
            eaction may set it.

  tc_classid: Actions may set it to overwrite the result of a classifer,
              meta ematch may read it and I guess meta eaction may
              write to it.

  tc_verd: Set early in net stack, used to track location and tc
           relevant flags.

  tclassid: Set withing routing db, may be read via meta ematch.

At the moment all of them can be described properly and it should be
easy to understand if the relations are outlined properly.

Assuming we allow setting tc_classid to overwrite the sfq internal
hash we introduce a not so obvious double use because tc_classid is
assumed to at least partly point to a class. We can redefine tc_classid
as being a generic flow/session descriptor but then it should be moved
out of being used to overwrite the classid within actions. Assuming I
have a classifier which normally classifies into a child class but
sometimes I want the traffic to go into a leaf sfq qdisc by using the
action to overwrite the result. It will then be impossible to overwrite
the sfq hash because I would no longer be able to overwrite the
classifier result. It's probably possible to find some working solution
by having the minor part being the sfq input or vice versa but it
gets really nasty. Therefore I think we should make a difference between
the current use of tc_classid to overwrite the classifier result and
giving qdiscs some kind of input not directly related to their handle.

Thoughts?
