From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 0/4] Fix race between sk_filter reassign and sk_clone()
Date: Wed, 17 Oct 2007 13:45:54 +0400
Message-ID: <4715D9D2.8070102@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:39062 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752459AbXJQJse (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 05:48:34 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The race can result in that some sock will get an sk_filter
pointer set to kfree-d memory. Look

CPU1:                            CPU2:
sk_clone():                      sk_attach_filter():
  new_sk = sk_alloc(...);
  sock_copy(new_sk, sk); 
  /* copies the filter ptr */
  ...
  filter = new_sk->sk_filter;
  if (filter)
                                     old_fp = sk->sk_filter;
                                     ...
                                     sk_filter_release(old_fp);
                                       if (atomic_dec_and_test(&old_fp->refcnt))
     atomic_inc(&filter->refcnt);
                                          /* true */
                                          call_rcu(&fp->rcu, kfree);

that's it - after a quiescent state pass the new_sk will have 
a pointer on kfree-d filter.

The same problem exists for detaching filter (SO_DETACH_FILTER).

The proposed fix consists of 3 preparation patches and the fix itself.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
