From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Issue with connector/netlink
Date: Fri, 30 Mar 2007 11:37:53 +0400
Message-ID: <20070330073753.GB20739@2ka.mipt.ru>
References: <200703292047.19208.philipp.reisner@linbit.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: Philipp Reisner <philipp.reisner@linbit.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:53655 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751771AbXC3Hix (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Mar 2007 03:38:53 -0400
Content-Disposition: inline
In-Reply-To: <200703292047.19208.philipp.reisner@linbit.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Philipp.

On Thu, Mar 29, 2007 at 08:47:18PM +0200, Philipp Reisner (philipp.reisner@linbit.com) wrote:
> It happens in netlink_broadcast() which seems to get called
> from drbd_connector_callback(). Drbd_connector_callback() 
> calls cn_netlink_send(), which in turn calls netlink_broadcast().
>    I guess this little detail is missing from the trace since
>    the call to netlink_broadcast() happens with the return
>    statement in cn_netlink_send().
> 
> netlink_broadcast() in turn calls the inlined function
> do_one_broadcast(), in which the OOPS happens. It is the test_bit()
> call!
> 
> static inline int do_one_broadcast(struct sock *sk,
>                                    struct netlink_broadcast_data *p)
> {
>         struct netlink_sock *nlk = nlk_sk(sk);
>         int val;
> 
>         if (p->exclude_sk == sk)
>                 goto out;
> 
>         if (nlk->pid == p->pid || p->group - 1 >= nlk->ngroups ||
>             !test_bit(p->group - 1, nlk->groups)) <=<<==<<<===<<<<====<<<<<======

That means nlk is broken, which seems to be very strange, probably it is
related to double freeing somewhere (or vrong are freeing).
Let's first assume connector is guilty, can you reproduce crash with
following patch:

diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index a905f78..aed7dd7 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -146,6 +146,7 @@ static int cn_call_callback(struct cn_msg *msg, void (*destruct_data)(void *), v
 							&__cbq->work))
 					err = 0;
 			} else {
+#if 0
 				struct cn_callback_data *d;
 				
 				err = -ENOMEM;
@@ -169,6 +170,7 @@ static int cn_call_callback(struct cn_msg *msg, void (*destruct_data)(void *), v
 						err = -EINVAL;
 					}
 				}
+#endif
 			}
 			break;
 		}

-- 
	Evgeniy Polyakov
