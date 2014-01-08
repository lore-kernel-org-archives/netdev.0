From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 2/3] virtio-net: use per-receive queue page frag
	alloc for mergeable bufs
Date: Wed, 8 Jan 2014 19:21:04 +0200
Message-ID: <20140108172104.GD17404@redhat.com>
References: <1387239389-13216-1-git-send-email-mwdalton@google.com>
	<1387239389-13216-2-git-send-email-mwdalton@google.com>
	<52B7F065.3010707@redhat.com>
	<1387819627.12212.4.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131223193704.GC1582@redhat.com>
	<CANJ5vPLEV_Z-D-0tThwhWXbHVaRWOLv566Xk1eD4TNYqNvknHw@mail.gmail.com>
	<20131226213727.GA10259@redhat.com>
	<1388095258.12212.37.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, netdev@vger.kernel.org,
	lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1388095258.12212.37.camel@edumazet-glaptop2.roam.corp.google.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 26, 2013 at 02:00:58PM -0800, Eric Dumazet wrote:
> On Thu, 2013-12-26 at 23:37 +0200, Michael S. Tsirkin wrote:
> 
> > Interesting. But if we can't allocate a buffer how can we
> > do network processing?
> 
> How typical NIC drivers handle this case ?
> 
> Answer : nothing special should happen, we drop incoming traffic,
> and make sure the driver recovers properly. (like not NULL deref or
> crazy things like that)
> 
> Why virtio_net should be different ?

Basically yes, we could start dropping packets immediately
once GFP_ATOMIC allocations fail and repost the buffer to host,
and hope memory is available by the time we get the next interrupt.
But we wanted host to have visibility into the fact that
we are out of memory and packets are dropped, so we did not want to
repost.
If we don't repost how do we know memory is finally available?
We went for a timer based workqueue thing.
What do you suggest?



> > 
> > If we can reproduce the problem, we can maybe move
> > allocation out of napi disabled section, but then
> > we'll need to add more locking.
> 
> More exactly, use appropriate locking ;)
> 
