From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] string matching ematch
Date: Thu, 27 Jan 2005 15:20:29 +0100
Message-ID: <20050127142029.GR31837@postel.suug.ch>
References: <20050126150714.GL31837@postel.suug.ch> <20050126130323.2dc10187.davem@davemloft.net> <20050126214119.GP31837@postel.suug.ch> <20050126152609.59e1a15e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, kaber@trash.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050126152609.59e1a15e.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20050126152609.59e1a15e.davem@davemloft.net> 2005-01-26 15:26
> On Wed, 26 Jan 2005 22:41:19 +0100
> Thomas Graf <tgraf@suug.ch> wrote:
> 
> > I'm not sure if mixing stateful with stateless stuff is such of a good
> > idea. I think it should be separated and have stateful filters only be
> > executed when the flow matters, not packets.
> 
> I think keeping things totally stateless would be the best
> idea.

Yes, I think so too.

I'm still thinking about pskbs in the background and the problem gets
more serious with this. So far, even with the multi byte ematch, all
filters were focusing on header content even if they were able to read
from any offset. 

Our goal must of course be to to avoid lineraization for as many cases
as possible, therefore I think it would be worth making all matchers
aware of pskbs without linearization. In case the packet goes though
the pedit or ipt action later on then we definitely need to take further
actions but these should be special cases.

For the string matching it is fairly easy, we can check for partial
matches at the end and begin of every fragment. The multi byte
ematch could be splitted into two paths, a fast path using memcmp
directly on the skb data for linear skbs and a "slow" path for
non-linear skbs fetching the needed byte sequence from the relevant
fragments first. The cmp ematch and u32 ematch and classifier could
fetch the needed bucket via a function tcf_read_at_offset taking
an offset and the length of the bucket {8|16|32} which iterates
over the fragments as needed. I know, for most cases it is not needed
but it shouldn't cost us too much.

Thoughts?
