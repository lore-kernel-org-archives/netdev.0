From: jamal <hadi@cyberus.ca>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: 28 Dec 2004 11:36:58 -0500
Message-ID: <1104251817.1090.164.camel@jzny.localdomain>
References: <200412270715.iBR7Fffe026855@hera.kernel.org>
	 <20041227121658.GI7884@postel.suug.ch>
	 <1104240053.1100.53.camel@jzny.localdomain>
	 <20041228134022.GA32419@postel.suug.ch>
	 <1104242397.1090.94.camel@jzny.localdomain>
	 <20041228161117.GD32419@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041228161117.GD32419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-12-28 at 11:11, Thomas Graf wrote:
> > If you implement the mothership match changes we discussed then it
> > should go as a match (as opposed to action). As an action its yet
> > another deferal for later cleanup.
> 
> What about this...
> 
> We introduce a new API tcf_exts which holds all the things on top of
> a classifier. There might be several instaces per classifier, i.e. one
> per filter for u32 and fw and one per hash bucket for route/tcindex,
> etc.
> 
> The classifier no longer knows about action/police/meta/... you name it
> but rather forwards the TLV TCA_..._EXTS to the extensions API. Backward
> compatibility is provided in the API (very simple).
> 

I think this sounds cleaner but is major surgery. The other issue i have
with it is semantically i see classification followed by actions.
Classification may have extended classification within it. Actions may
also have extended actions within them.
The majority of the surgery is going to be in ensuring that you can mix
and match actions, extended filters and extended actions.

> The extension infrastructure builds a tree to implement logic
> expressions where each node can be one of the supported types.
> 
> The action code would be transformed to an extension which would
> mean that there could be multiple action chains. Example:
> 
>  cls -+ meta indev=ppp0
>       |    \ <and> meta assign nfmark=2
>       |             \ <and> action:gact redirect
>  <or> |
>       \ meta nfmark=0x20
>            \ <and> action:mirred
> 
> Every extension node has a unique handle in the namespace of the tree.
> Deletion of a node results in deletion of all sub nodes.
> 
> Configuration must go via change routine of classifier or via tp->get()
> and some generic way to retrieve extension handle from classifier.
> 
> Thoughts?

Note my concerns above - we are talking major splicing!

Heres another approach:
The classifier is blind while executing those actions.
Data that needs to be embeded within the classifier is:
struct {extmatch type:extmatch void_data}.
extmatch_classify(extmatchdatastruct,skb) is a generic call which does a
lookup on the type and calls the proper callback. Callbacks return
standard classifier ret codes.
So an indev matcher will take the skb and compare against the indev data
stored in struct->void_data.
Only other call i can see needed is a registration function. extended
matchers register a callback and type.
user space stuff is easy.
Now with above i dont see how to fit your logical experssions - but its
a simple change and fits the requirement of writting the one page
extended matcher. The same thought could be extended to actions.
Sounds too easy unless i am intoxicated with the double-doubles i have
been conmsuming last few hours;->

thoughts?

cheers,
jamal
