From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: Tue, 28 Dec 2004 17:11:17 +0100
Message-ID: <20041228161117.GD32419@postel.suug.ch>
References: <200412270715.iBR7Fffe026855@hera.kernel.org> <20041227121658.GI7884@postel.suug.ch> <1104240053.1100.53.camel@jzny.localdomain> <20041228134022.GA32419@postel.suug.ch> <1104242397.1090.94.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104242397.1090.94.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> If you implement the mothership match changes we discussed then it
> should go as a match (as opposed to action). As an action its yet
> another deferal for later cleanup.

What about this...

We introduce a new API tcf_exts which holds all the things on top of
a classifier. There might be several instaces per classifier, i.e. one
per filter for u32 and fw and one per hash bucket for route/tcindex,
etc.

The classifier no longer knows about action/police/meta/... you name it
but rather forwards the TLV TCA_..._EXTS to the extensions API. Backward
compatibility is provided in the API (very simple).

The extension infrastructure builds a tree to implement logic
expressions where each node can be one of the supported types.

The action code would be transformed to an extension which would
mean that there could be multiple action chains. Example:

 cls -+ meta indev=ppp0
      |    \ <and> meta assign nfmark=2
      |             \ <and> action:gact redirect
 <or> |
      \ meta nfmark=0x20
           \ <and> action:mirred

Every extension node has a unique handle in the namespace of the tree.
Deletion of a node results in deletion of all sub nodes.

Configuration must go via change routine of classifier or via tp->get()
and some generic way to retrieve extension handle from classifier.

Thoughts?
