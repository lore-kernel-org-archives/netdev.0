From: jamal <hadi@cyberus.ca>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: 28 Dec 2004 18:06:37 -0500
Message-ID: <1104275197.1100.276.camel@jzny.localdomain>
References: <1104252710.1090.171.camel@jzny.localdomain>
	 <200412270715.iBR7Fffe026855@hera.kernel.org>
	 <20041227121658.GI7884@postel.suug.ch>
	 <1104240053.1100.53.camel@jzny.localdomain>
	 <20041228134022.GA32419@postel.suug.ch>
	 <1104242397.1090.94.camel@jzny.localdomain>
	 <20041228161117.GD32419@postel.suug.ch>
	 <1104251817.1090.164.camel@jzny.localdomain>
	 <20041228192603.GE32419@postel.suug.ch>
	 <1104268498.1090.254.camel@jzny.localdomain>
	 <20041228221021.GF32419@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041228221021.GF32419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-12-28 at 17:10, Thomas Graf wrote:
> * jamal <1104268498.1090.254.camel@jzny.localdomain> 2004-12-28 16:14
> > Whatever you had before is fine for action/policer - with intent to kill
> > policer eventually.
> 
> I left it in for now but I see no reason why to do so actually. Old
> iproute2 binaries should do just fine with the action backward
> compatibility code?
> 

Its maintainance work. Nothing it provides isnt provided by
new policer. 

> > What i objected to is the indev and any other thing that has to do with
> > classification helping - thats not where it should fit.
> > Take u32 for example: The fit for match extensions is really at the key
> > level not at a layer above.
> > We need a sel2 which has new keys (which is easy because thats
> > transported in a TLV).
> 
> Take a look at http://people.suug.ch/~tgr/patches/queue/03_tcf_exts_u32.diff
> 
> The extensions are on the same level as the selector. 

Ok, i see we may be talking about two separate things:->
that patch is fine for policer/action (I noticed you removed indev -
good thing). 
It is not proper spot for the matches and infact
should go in as a separate patch altogether (relation is very minimal).

For the matches, the checks are going to be per key _not_ at the
selector level; i.e:

struct tc_newu32_key
{
        __u32           mask;
        __u32           val;
        int             off;
        int             offmask;
	pointer to extendedmatches here.
};

Since these keys are packed in a selector and the selector is what gets
transported from/to user space we need a selector2 which packs these new
keys instead. Makes sense? i.e need a TCA_U32_SEL2 where the extended
matches are stored. 
Backward compatibility: New TC transports them in addition to
TCA_U32_SEL and old kernels ignore them.
old TC doesnt send them so new kernels can handle them just fine. Beauty
of TLVs.

Your check in the classifier is 
if (matched) {
	if (NULL != key.pointertoematch) {
		ret = call the generic ematch function
		if ret == OK
			continue with next match
		else failed
	}
}

u32_change receives the extended matches and populates them accordingly.
There is no need for a dump fucntion to exist for them. They get shipped
back the same way they came in - user space knows how to dump them.
a  key.pointertoematch could be infact a llist of these items. So the
struct looks like:

struct tcf_ematch_info
{
        
	struct tcf_ematch_info *next;
        __u32           type
        void		*data;
        may need a datalen here for dumping back to user space.
};

Makes sense?

Back to what i said earlier i can now write a single page of code
to scan for word "Thomas" if i get a match on TCP port 25 for all IP
addresses... i.e metadata is a subset of all this.


cheers,
jamal
