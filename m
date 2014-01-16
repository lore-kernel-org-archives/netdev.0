From: Michael Dalton <mwdalton@google.com>
Subject: Re: [PATCH net-next v3 5/5] virtio-net: initial rx sysfs support,
	export mergeable rx buffer size
Date: Thu, 16 Jan 2014 09:27:08 -0800
Message-ID: <CANJ5vPJi=k1Wk43j+-XjSgnnAS5uO9wrYQuDnrdfA5A+DGxvQg@mail.gmail.com>
References: <1389865126-26225-1-git-send-email-mwdalton@google.com>
	<1389865126-26225-5-git-send-email-mwdalton@google.com>
	<20140116115340.GC29061@redhat.com>
	<CANJ5vPJZACr=y3uRv0Rnq330jQCi4dLvhyQd88ascZjBg_jfUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CANJ5vPJZACr=y3uRv0Rnq330jQCi4dLvhyQd88ascZjBg_jfUw@mail.gmail.com>
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

Sorry, just realized - I think disabling NAPI is necessary but not
sufficient. There is also the issue that refill_work() could be
scheduled. If refill_work() executes, it will re-enable NAPI. We'd need
to cancel the vi->refill delayed work to prevent this AFAICT, and also
ensure that no other function re-schedules vi->refill or re-enables NAPI
(virtnet_open/close, virtnet_set_queues, and virtnet_freeze/restore).

How is the following sequence of operations:
rtnl_lock();
cancel_delayed_work_sync(&vi->refill);
napi_disable(&rq->napi);
read rq->mrg_avg_pkt_len
virtnet_enable_napi();
rtnl_unlock();

Additionally, if we disable NAPI when reading this file, perhaps
the permissions should be changed to 400 so that an unprivileged
user cannot temporarily disable network RX processing by reading these
sysfs files. Does that sound reasonable?

Best,

Mike
