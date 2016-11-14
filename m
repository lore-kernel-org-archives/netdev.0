From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Long delays creating a netns after deleting one (possibly RCU related)
Date: Mon, 14 Nov 2016 16:12:54 -0600
Message-ID: <87y40lhfrt.fsf@xmission.com>
References: <CA+pO-2f+7QfsLiFwvGcNqTrQ0t8B5+w0vZHFrshWsSWgDE6iUg@mail.gmail.com>
        <CAM_iQpUNRyv3wHi3cJpcH6avo+D7Gxwqp+iybUxYc7PCo3WUPw@mail.gmail.com>
        <20161110212404.GB4127@linux.vnet.ibm.com>
        <CA+pO-2ddoJYvhVoV3Bo+-3K7V63eY9sbKzKwYrut65GZXs6_1g@mail.gmail.com>
        <20161112002347.GL4127@linux.vnet.ibm.com>
        <CAM_iQpUDnPfVayQv7Q+ZtC_2_ZbX9MRX=514gFpF3E6XY+GtSA@mail.gmail.com>
        <CAM_iQpUq14GsvGyz2xA1PkDq5YO743T68Zh2zm=NJZQ9S2Ahqg@mail.gmail.com>
        <20161114162417.GJ4127@linux.vnet.ibm.com>
        <CAM_iQpXL+JaVG86+h2ucYs4Dm0zJKHq+4Nm+gk75wESGOzTmJQ@mail.gmail.com>
        <20161114181425.GN4127@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Rolf Neugebauer <rolf.neugebauer@docker.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Justin Cormack <justin.cormack@docker.com>,
        Ian Campbell <ian.campbell@docker.com>,
        <netdev@vger.kernel.org>, Eric Dumazet <edumazet@google.com>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161114181425.GN4127@linux.vnet.ibm.com> (Paul E. McKenney's
        message of "Mon, 14 Nov 2016 10:14:25 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Paul E. McKenney" <paulmck@linux.vnet.ibm.com> writes:

> On Mon, Nov 14, 2016 at 09:44:35AM -0800, Cong Wang wrote:
>> On Mon, Nov 14, 2016 at 8:24 AM, Paul E. McKenney
>> <paulmck@linux.vnet.ibm.com> wrote:
>> > On Sun, Nov 13, 2016 at 10:47:01PM -0800, Cong Wang wrote:
>> >> On Fri, Nov 11, 2016 at 4:55 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> >> > On Fri, Nov 11, 2016 at 4:23 PM, Paul E. McKenney
>> >> > <paulmck@linux.vnet.ibm.com> wrote:
>> >> >>
>> >> >> Ah!  This net_mutex is different than RTNL.  Should synchronize_net() be
>> >> >> modified to check for net_mutex being held in addition to the current
>> >> >> checks for RTNL being held?
>> >> >>
>> >> >
>> >> > Good point!
>> >> >
>> >> > Like commit be3fc413da9eb17cce0991f214ab0, checking
>> >> > for net_mutex for this case seems to be an optimization, I assume
>> >> > synchronize_rcu_expedited() and synchronize_rcu() have the same
>> >> > behavior...
>> >>
>> >> Thinking a bit more, I think commit be3fc413da9eb17cce0991f
>> >> gets wrong on rtnl_is_locked(), the lock could be locked by other
>> >> process not by the current one, therefore it should be
>> >> lockdep_rtnl_is_held() which, however, is defined only when LOCKDEP
>> >> is enabled... Sigh.
>> >>
>> >> I don't see any better way than letting callers decide if they want the
>> >> expedited version or not, but this requires changes of all callers of
>> >> synchronize_net(). Hm.
>> >
>> > I must confess that I don't understand how it would help to use an
>> > expedited grace period when some other process is holding RTNL.
>> > In contrast, I do well understand how it helps when the current process
>> > is holding RTNL.
>> 
>> Yeah, this is exactly my point. And same for ASSERT_RTNL() which checks
>> rtnl_is_locked(), clearly we need to assert "it is held by the current process"
>> rather than "it is locked by whatever process".
>> 
>> But given *_is_held() is always defined by LOCKDEP, so we probably need
>> mutex to provide such a helper directly, mutex->owner is not always defined
>> either. :-/
>
> There is always the option of making acquisition and release set a per-task
> variable that can be tested.  (Where did I put that asbestos suit, anyway?)
>
> 							Thanx, Paul

synchronize_rcu_expidited is not enough if you have multiple network
devices in play.

Looking at the code it comes down to this commit, and it appears there
is a promise add rcu grace period combining by Eric Dumazet.

Eric since people are hitting noticable stalls because of the rcu grace
period taking a long time do you think you could look at this code path
a bit more?

commit 93d05d4a320cb16712bb3d57a9658f395d8cecb9
Author: Eric Dumazet <edumazet@google.com>
Date:   Wed Nov 18 06:31:03 2015 -0800

    net: provide generic busy polling to all NAPI drivers
    
    NAPI drivers no longer need to observe a particular protocol
    to benefit from busy polling (CONFIG_NET_RX_BUSY_POLL=y)
    
    napi_hash_add() and napi_hash_del() are automatically called
    from core networking stack, respectively from
    netif_napi_add() and netif_napi_del()
    
    This patch depends on free_netdev() and netif_napi_del() being
    called from process context, which seems to be the norm.
    
    Drivers might still prefer to call napi_hash_del() on their
    own, since they might combine all the rcu grace periods into
    a single one, knowing their NAPI structures lifetime, while
    core networking stack has no idea of a possible combining.
    
    Once this patch proves to not bring serious regressions,
    we will cleanup drivers to either remove napi_hash_del()
    or provide appropriate rcu grace periods combining.
    
    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

Eric
