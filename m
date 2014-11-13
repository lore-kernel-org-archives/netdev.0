From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 88111] New: Race condition in net_tx_action?
Date: Wed, 12 Nov 2014 22:19:49 -0500
Message-ID: <20141112221949.2018701d@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:54052 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751279AbaKXT1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 14:27:31 -0500
Received: by mail-pa0-f48.google.com with SMTP id rd3so10110511pab.21
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 11:27:31 -0800 (PST)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by mx.google.com with ESMTPSA id h1sm13238707pat.6.2014.11.24.11.27.29
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Nov 2014 11:27:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 12 Nov 2014 10:52:10 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 88111] New: Race condition in net_tx_action?


https://bugzilla.kernel.org/show_bug.cgi?id=88111

            Bug ID: 88111
           Summary: Race condition in net_tx_action?
           Product: Networking
           Version: 2.5
    Kernel Version: all
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: angelo.rizzi@3dautomazione.it
        Regression: No

Hi all,

I have a question about a strange situation i've faced on my linux-based
embedded system:

Using 2 network device (transmitting asynchronously), i found a kind of "leak"
in sk_buff alloc/free that drives my test program, after some days of
continuous transmission, to be unable to write on the xmitting socket ("poll()"
function using POLLOUT request always returning 0).

After a lot of test, i've found the reason for such behaviour in the
net_tx_action() function (net/core/dev.c):

Let me explain what i've found:

The following code is used in order to get the current list of sk_buff to free:

static void net_tx_action(struct softirq_action *h)
{
        struct softnet_data *sd = &__get_cpu_var(softnet_data);

        if (sd->completion_queue) {
                 struct sk_buff *clist;

                 local_irq_disable();
                 clist = sd->completion_queue;
                 sd->completion_queue = NULL;
                 local_irq_enable();

Transmitting asynchronously on all the network devices available i've noticed
the following behaviour:
a) The instruction "if (sd->completion_queue) {" saves on a CPU register the
pointer value (register contents is used for the comparison)
b) The interupt is disabled (using "local_irq_disable")
c) when the content of "clist" is updated, the register is used, instead of
re-read the "completion_queue" variable.

So, when a low-level tx interrupt arrives after the latching of
"completion_queue", but before "local_irq_disable", the value stored in "clist"
reflect the situation before low-level tx interrupt, resulting in a sk_buff
leak

I've changed the declaration of "sd" as follows:

        volatile struct softnet_data *sd = &__get_cpu_var(softnet_data);

and everything is now ok.

Is that correct?

Thanks,
Angelo

-- 
You are receiving this mail because:
You are the assignee for the bug.
