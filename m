From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Patch net-next] net: make neigh tables per netns
Date: Mon, 30 Jun 2014 20:54:34 +0200
Message-ID: <1404154474.14692.136223169.48BE9C85@webmail.messagingengine.com>
References: <87lhskpizv.fsf@x220.int.ebiederm.org>
 <20140626.134335.2147671135749217539.davem@davemloft.net>
 <87egybibh5.fsf@x220.int.ebiederm.org>
 <20140626.154428.1099304313432511688.davem@davemloft.net>
 <CAM_iQpX7iPR=32kog=QJm4G1tgRfg80Hr8Y=BOgUiGnym5EmKw@mail.gmail.com>
 <87vbrl8vmz.fsf@x220.int.ebiederm.org>
 <20140630201518.653ebbaf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <cwang@twopensource.com>,
	Stefan Bader <stefan.bader@canonical.com>,
	stephane.graber@canonical.com, chris.j.arges@canonical.com,
	Serge Hallyn <serge.hallyn@canonical.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:58198 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751001AbaF3Syi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 14:54:38 -0400
In-Reply-To: <20140630201518.653ebbaf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Jun 30, 2014, at 20:15, Jesper Dangaard Brouer wrote:
> 
> On Fri, 27 Jun 2014 22:12:52 -0700 ebiederm@xmission.com (Eric W.
> Biederman) wrote:
> > Cong Wang <xiyou.wangcong@gmail.com> writes:
> > > On Thu, Jun 26, 2014 at 3:44 PM, David Miller <davem@davemloft.net> wrote:
> > >>
> [...]
> > >
> > > Hmm, I did overlook the potential DOS problem. But hold on, isn't
> > > IP fragments have the same problem? The fragment queues are per
> > > netns, and the thresh is per netns as well, we will eventually have
> > > memory pressure as well.
> > 
> > Interesting.  It does look like ip fragments are susceptible that way.
> 
> For IP fragments we have per netns mem-limit and LRU-list, but all
> netns share the same hash table, which have its own DoS potential.
> 
> And argh! - we have a hardcoded INETFRAGS_MAXDEPTH=128, which can be
> used for (slow) DoS of IP frags if enough netns are created.
> 
> https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/tree/net/ipv4/inet_fragment.c#n344
> 
> Introduced by commit 5a3da1fe9 ("inet: limit length of fragment queue
> hash table bucket lists").

Sure, but we need that, otherwise even a single netns can get exploited
up to a remotely triggered lockup of the box - e.g.
https://gist.github.com/hannes/5116331 - on some smaller machines.
INETFRAGS_MAXDEPTH is a property of the hashtable and walking a chain
with more than 128 elements is just crazy.

Also, for me making this user configurable doesn't seem to provide a
benefit.

Sure, it does introduce some kind of unfairness between the namespaces,
but so does all code which overcommits shared resources.

Bye,
Hannes
