From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Long delays creating a netns after deleting one (possibly RCU related)
Date: Fri, 11 Nov 2016 16:55:11 -0800
Message-ID: <CAM_iQpUDnPfVayQv7Q+ZtC_2_ZbX9MRX=514gFpF3E6XY+GtSA@mail.gmail.com>
References: <CA+pO-2f+7QfsLiFwvGcNqTrQ0t8B5+w0vZHFrshWsSWgDE6iUg@mail.gmail.com>
 <CAM_iQpUNRyv3wHi3cJpcH6avo+D7Gxwqp+iybUxYc7PCo3WUPw@mail.gmail.com>
 <20161110212404.GB4127@linux.vnet.ibm.com> <CA+pO-2ddoJYvhVoV3Bo+-3K7V63eY9sbKzKwYrut65GZXs6_1g@mail.gmail.com>
 <20161112002347.GL4127@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rolf Neugebauer <rolf.neugebauer@docker.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Justin Cormack <justin.cormack@docker.com>,
        Ian Campbell <ian.campbell@docker.com>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161112002347.GL4127@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 11, 2016 at 4:23 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
>
> Ah!  This net_mutex is different than RTNL.  Should synchronize_net() be
> modified to check for net_mutex being held in addition to the current
> checks for RTNL being held?
>

Good point!

Like commit be3fc413da9eb17cce0991f214ab0, checking
for net_mutex for this case seems to be an optimization, I assume
synchronize_rcu_expedited() and synchronize_rcu() have the same
behavior...

diff --git a/net/core/dev.c b/net/core/dev.c
index eaad4c2..3415b6b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7762,7 +7762,7 @@ EXPORT_SYMBOL(free_netdev);
 void synchronize_net(void)
 {
        might_sleep();
-       if (rtnl_is_locked())
+       if (rtnl_is_locked() || lockdep_is_held(&net_mutex))
                synchronize_rcu_expedited();
        else
                synchronize_rcu();
