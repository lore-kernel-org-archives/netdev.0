From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Long delays creating a netns after deleting one (possibly RCU related)
Date: Sun, 13 Nov 2016 22:47:01 -0800
Message-ID: <CAM_iQpUq14GsvGyz2xA1PkDq5YO743T68Zh2zm=NJZQ9S2Ahqg@mail.gmail.com>
References: <CA+pO-2f+7QfsLiFwvGcNqTrQ0t8B5+w0vZHFrshWsSWgDE6iUg@mail.gmail.com>
 <CAM_iQpUNRyv3wHi3cJpcH6avo+D7Gxwqp+iybUxYc7PCo3WUPw@mail.gmail.com>
 <20161110212404.GB4127@linux.vnet.ibm.com> <CA+pO-2ddoJYvhVoV3Bo+-3K7V63eY9sbKzKwYrut65GZXs6_1g@mail.gmail.com>
 <20161112002347.GL4127@linux.vnet.ibm.com> <CAM_iQpUDnPfVayQv7Q+ZtC_2_ZbX9MRX=514gFpF3E6XY+GtSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rolf Neugebauer <rolf.neugebauer@docker.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Justin Cormack <justin.cormack@docker.com>,
        Ian Campbell <ian.campbell@docker.com>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpUDnPfVayQv7Q+ZtC_2_ZbX9MRX=514gFpF3E6XY+GtSA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 11, 2016 at 4:55 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Fri, Nov 11, 2016 at 4:23 PM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
>>
>> Ah!  This net_mutex is different than RTNL.  Should synchronize_net() be
>> modified to check for net_mutex being held in addition to the current
>> checks for RTNL being held?
>>
>
> Good point!
>
> Like commit be3fc413da9eb17cce0991f214ab0, checking
> for net_mutex for this case seems to be an optimization, I assume
> synchronize_rcu_expedited() and synchronize_rcu() have the same
> behavior...

Thinking a bit more, I think commit be3fc413da9eb17cce0991f
gets wrong on rtnl_is_locked(), the lock could be locked by other
process not by the current one, therefore it should be
lockdep_rtnl_is_held() which, however, is defined only when LOCKDEP
is enabled... Sigh.

I don't see any better way than letting callers decide if they want the
expedited version or not, but this requires changes of all callers of
synchronize_net(). Hm.
