From: "Ravinandan Arakali \(rarakali\)" <rarakali@cisco.com>
Subject: Clarification required about select vs wake_up race condition
Date: Mon, 12 Mar 2007 19:38:10 -0700
Message-ID: <FA6FB5FA4DA6BF4386D129273B2E3EC30183A413@xmb-sjc-214.amer.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:22218 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753065AbXCMCrp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 22:47:45 -0400
Received: from sj-core-2.cisco.com (sj-core-2.cisco.com [171.71.177.254])
	by sj-dkim-2.cisco.com (8.12.11/8.12.11) with ESMTP id l2D2cAcP008661
	for <netdev@vger.kernel.org>; Mon, 12 Mar 2007 19:38:10 -0700
Received: from xbh-sjc-211.amer.cisco.com (xbh-sjc-211.cisco.com [171.70.151.144])
	by sj-core-2.cisco.com (8.12.10/8.12.6) with ESMTP id l2D2cA1V022937
	for <netdev@vger.kernel.org>; Tue, 13 Mar 2007 02:38:10 GMT
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
I am facing following problem and was wondering if somebody could help
me out.
I reference our char driver below but the question I really have is
about sleep/wake_up mechanism. So, I thought somebody who is aware of
this can help me. BTW, this is 2.6.10.

Our char driver(pretty much like all other char drivers) does a
poll_wait() 
and returns status depending on whether data is available to be read.
Even though some data is available to be read(verified using one of our
internal 
commands), the select() never wakes up, inspite of any no. of messages
sent.

To understand this, I was looking at the code of select vs
wake_up_interruptible().
I feel I am misunderstanding some part of the kernel code but will be
glad if 
somebody can point it out.

My understanding:
The do_select() sets the state of task to TASK_INTERRUPTIBLE and calls
the driver's poll 
entry point. In our poll(), let's say immediately after we determine
that there's nothing 
to be read, some data arrives causing a wake_up_interruptible() on
another CPU. 
The wake up happens in the context of process sending the data. Since
the receiving process 
was already added to the list of listeners, from looking at the code of
try_to_wake_up(), it 
looks like it can set the state of the receiving process to
TASK_RUNNING(I don't see any lock 
preventing this). After this happens, the receiving process goes to
sleep (because of 
schedule_timeout called by do_select) but state is still set to
TASK_RUNNING. In this state, when another message arrives, the
wake_up_interruptible will not wake the process because of following 
code in try_to_wake_up() ?

old_state = p->state;
if (!(old_state & state))
   goto out;

The above situation seems simplistic so I'm wondering what I am missing
here ?

Thanks,
Ravi
