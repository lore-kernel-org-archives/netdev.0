From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] string matching ematch
Date: Wed, 26 Jan 2005 22:41:19 +0100
Message-ID: <20050126214119.GP31837@postel.suug.ch>
References: <20050126150714.GL31837@postel.suug.ch> <20050126130323.2dc10187.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, kaber@trash.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050126130323.2dc10187.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20050126130323.2dc10187.davem@davemloft.net> 2005-01-26 13:03
> On Wed, 26 Jan 2005 16:07:14 +0100
> Thomas Graf <tgraf@suug.ch> wrote:
> 
> > I'd like to discuss the string matching ematch, I don't care about the
> > algorithm used but rather whether to make it stateful, match over
> > fragments, etc.
> 
> I think you'll need to make it stateful.
> 
> I assume this is meant to be used for things like catching references
> to "Falun Gong" in SMTP sessions and stuff like that.  Not that I know
> any entity interested in such applications :-)

Hehe, it's main purpose is to catch mail from your sweetie and redirect
them through a low latency link but of course you can also use it to
match on text based protocols without strict header ordering. ;->

> Anyways, if the string goes across the TCP data portion of multiple
> packets, statefulness becomes necessary to catch it.  Right?

Yes and no, it is of course necessary if one wants to match any string
at any position without limitation. OTOH, it gets quite complex. We'd
have to store the state of every configured kmp ematch to just be
able to tell the result. On top of that, the whole classification
process is stateless and should be kept like this. Assuming one
configures three ematches like this:

u32(ip dport 333 0xff)
and (
  kmp("Falun Gong" from 20 layer transport)
  and nbyte("SMTP" at 0 layer application)
)

assuming the u32 and nbyte ematch matches in the first packet, the
string matches only partially. We can't regard regard the ematch
tree as matched so we must return false. The next packet in the flow
completes the string but the nbyte match doesn't match anymore
so no match either. In fact a stateless filter can't do any better
but it doesn't consume as much resources.

There are cases where a statefull string matching would be of use, one
of them is when it doesn't matter which packet you actually classify,
e.g. dropping connections such as to protect your web server from stilly
requests.

I'm not sure if mixing stateful with stateless stuff is such of a good
idea. I think it should be separated and have stateful filters only be
executed when the flow matters, not packets.
