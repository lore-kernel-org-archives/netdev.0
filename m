From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net: add per device sg_max_frags for skb
Date: Wed, 13 Jan 2016 16:07:09 +0100
Message-ID: <5696681D.4060002@stressinduktion.org>
References: <1452086182-26748-1-git-send-email-hans.westgaard.ry@oracle.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CCBE5AA@AcuExch.aculab.com>
 <568F87AC.60405@oracle.com> <568FA1E5.7060204@stressinduktion.org>
 <569657D8.1020807@oracle.com>
 <CANn89iJtB1qJCbBWUTXFo2LRWobQe6aDFb_KEWUhBNiZCNpdWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@aculab.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Salam Noureddine <noureddine@arista.com>,
	Jarod Wilson <jarod@redhat.com>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Julian Anastasov <ja@ssi.bg>,
	Ying Xue <ying.xue@windriver.com>,
	Craig Gallek <kraig@google.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Edward Jee <edjee@google.com>,
	Julia Lawall <julia.lawall@lip6.fr>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kerne
To: Eric Dumazet <edumazet@google.com>,
	Hans Westgaard Ry <hans.westgaard.ry@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89iJtB1qJCbBWUTXFo2LRWobQe6aDFb_KEWUhBNiZCNpdWA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13.01.2016 15:19, Eric Dumazet wrote:
> 1) There are no arch with 1K page sizes. Most certainly, if we had
> MAX_SKB_FRAGS=65 some assumptions in the stack would fail.
>
> 2) TCP stack has coalescing support. write(2) or sendmsg(2) should
> append data into the last skb in write queue, and still use 32 KB
> frags.
>      You get pathological skb when using sendpage() or when one thread
> writes data into _multiple_ TCP sockets, since TCP stack uses
>      a per thread 32 KB reserve (
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=5640f7685831e088fe6c2e1f863a6805962f8e81
> )
>
> 2) As I said, implementing a limit in TCP stack is not enough. Your
> patch is therefore adding complexity for all users, but is not a
> general solution.
>
>     GRO, tun device, many things can still cook 'big skbs'
>
>      You need to properly implement a fallback, possibly using
> ndo_features_check(), or directly from your ndo_start_xmit()
>
> 3) We currently have a very dumb way to fallback, forcing a linearize
> call, likely to fail if memory is fragmented and skb big.
>
>      You could instead provide a smart helper, trying to reduce the
> number of frags in a skb by chosing adjacent frags and
> re-allocating/merging them.
>
>      By choosing, I mean trying to pick smallest ones to minimize copy
> cost, to get one skb with X less fragment. (X=1 in your case ?)
>
>     I know for example that bnx2x could benefit from such a helper, as
> it has a 13 frags limits.
>     (bnx2x_pkt_req_lin(), called from bnx2x ndo_start_xmit()

As I proposed, we could globally (or per netns) limit the maximum , I 
think this would be okay and could be the best alternative to install 
slow-paths which could be hit quite constantly.

Otherwise, the fallbacks like Eric proposed them are needed. I do not 
see any other choice.

Thanks,
Hannes
