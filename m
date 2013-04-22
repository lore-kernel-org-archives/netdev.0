From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v2 1/2] genl: Allow concurrent genl callbacks.
Date: Mon, 22 Apr 2013 16:49:05 -0700
Message-ID: <CALnjE+pg1ecFjisxnHyrMsBCyZ6daF=wCH+FxEc8XtCqAwyo6g@mail.gmail.com>
References: <1366320646-16903-1-git-send-email-pshelar@nicira.com>
	<20130422.161812.1075030033926378895.davem@davemloft.net>
	<CALnjE+pwo5_j8ChPEHGXWT2kc1U3mVE99xc=XDtp6XtPOytKGA@mail.gmail.com>
	<20130422.185521.711925108684466632.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, dev@openvswitch.org, jesse@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog133.obsmtp.com ([74.125.149.82]:40694 "HELO
	na3sys009aog133.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751474Ab3DVXtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 19:49:07 -0400
Received: by mail-qc0-f199.google.com with SMTP id p7so56352qcq.6
        for <netdev@vger.kernel.org>; Mon, 22 Apr 2013 16:49:06 -0700 (PDT)
In-Reply-To: <20130422.185521.711925108684466632.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 22, 2013 at 3:55 PM, David Miller <davem@davemloft.net> wrote:
> From: Pravin Shelar <pshelar@nicira.com>
> Date: Mon, 22 Apr 2013 13:41:41 -0700
>
>> Therefore scatchpad in SKB is protected and parallel netlink dump operations
>> can go only on different netlink sockets.
>
> What about configuration changes running in parallel with the dump?
>
> You must synchronize with those too, otherwise protecting the
> intra-dump state is meaningless since the underlying objects
> can change underneath the dump.

That is synchronized using rw-sem.
This is how locking looks like:

genl_dump() (if lockless = true)
  SEM_READ_LOCK()
  Per_sock_mutex()
  -->netlink_dump()
  Per_sock_unmutex()
  SEM_READ_UNLOCK()
---

genl_conf_changes:
  SEM_WRITE_LOCK()
  GENL_LOCK()
     conf_changes()
  GENL_UNLOCK()
  SEM_WRITE_UNLOCK()
---

Now I think I shld call this parallel operations rather than lockless
operations, since I do take read lock for entire genl-ops
.
Let me send updated patch.
