From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] tcf_bind_filter failure handling
Date: 13 Dec 2004 14:23:43 -0500
Message-ID: <1102965823.1075.14.camel@jzny.localdomain>
References: <20041110010113.GJ31969@postel.suug.ch>
	 <41916A91.3080107@trash.net> <20041110012251.GK31969@postel.suug.ch>
	 <41916F0B.5010809@trash.net> <20041110013941.GL31969@postel.suug.ch>
	 <41917330.6090002@trash.net> <20041212175736.GA8493@postel.suug.ch>
	 <41BC8819.7040501@trash.net> <20041213165302.GE8493@postel.suug.ch>
	 <41BDDB5A.9000907@trash.net>  <20041213185203.GF8493@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041213185203.GF8493@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


When/why would binding fail? tcindex is an exception.
I dont see binding as having any contribution to the error path.
Additional locking is not advisable. The binding could happen while
traffic is running.

cheers,
jamal 

On Mon, 2004-12-13 at 13:52, Thomas Graf wrote:
> * Patrick McHardy <41BDDB5A.9000907@trash.net> 2004-12-13 19:11
> > Thomas Graf wrote:
> > 
> > >The handling of a failure in tcf_bind_filter is inconsistent.
> > >
> > >u32: ignore
> > >fw: ignore
> > >route: ignore
> > >rsvp: ignore
> > >tcindex: error
> > >
> > >It might be a good idea to make this consistent. So in order to validate
> > >the classid before making any changes we could simply lock it via get
> > >(see patch below), return an error if it fails  and put it back in case
> > >of an error further in the path or after binding the filter.
> > >
> > >Bindings not only locks the class from removal while a filter is
> > >pointing to it. It speeds up classyfing by saving a lookup for every
> > >tc_classify call. It's not really a problem if the class is not locked,
> > >the qdisc will look it up and falls back to a default class if it
> > >doesn't exists so it's rather a cosmetic/policy thing.
> > >
> > You should just fix tcindex not to care about errors in tcf_bind_filter.
> > bind_tcf already locks the class. Some qdiscs (like prio) map bind_filter
> > to get, but others (HTB, HFSC, CBQ) use a seperate counter because it is
> > legal to end up with a refcnt > 0 after delete. When a class with filters
> > pointing to it is tried to destroy they return -EBUSY, which can't be done
> > by looking at the refcnt.
> 
> Little misunderstanding here. I'm not aiming at replacing tcf_bind_filter
> with get.  My question is rather whether to regard tcf_bind_filter not setting
> tcf_result->class as an error or ignore it. 
> 
> I'm all for ignoring it in tcindex, it requires some changes because
> it checks tcf_result.class field to see if hash bucket is non-empty if
> perfect hash is used but is not a problem at all.
> 
> The tcf_class_get/put would be required to ensure proper locking during
> validation of parameters if validating the classid being last before
> changing things doesn't make sense due to the need to undo expensive
> operations required before binding.
> 
> I will fix tcindex, since you also agree on simply ignoring it and regard
> the binding as an ptional locking and performance increase possibility
> given to userspace.
> 
> 
