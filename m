From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: netns refcnt leak for kernel accept sock
Date: Mon, 27 Jul 2015 20:50:02 +0200
Message-ID: <20150727185002.GA20334@oracle.com>
References: <20150727142146.GC16447@oracle.com>
 <CAHA+R7Pe08rfERd1rMR1Y_kK2iUm4TDc92rRhhJhr-e+_fsioA@mail.gmail.com>
 <20150727181946.GJ16447@oracle.com>
 <CAHA+R7PzsOCR-UmJ+73jXJaacc_adz9F3-Qs4zB0cSFajpJREw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:42514 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245AbbG0SuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 14:50:17 -0400
Content-Disposition: inline
In-Reply-To: <CAHA+R7PzsOCR-UmJ+73jXJaacc_adz9F3-Qs4zB0cSFajpJREw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (07/27/15 11:37), Cong Wang wrote:
> 
> dlm uses a kernel TCP socket too, but it allocates a new socket and calls
> ->accept() by itself. ;)

sure, and rds does this in rds_tcp_accept_one() too.

But the newsk being created in sk_clone_lock  is the one on an 
incoming syn, i.e., the one that is saved up as part of listen backlog, 
to be returned later on the accept.

I dont know the details of dlm- can you have one dlm instance per
network namespace? That's where I'm running into this issue- when we
try to have one rds listen socket per netns, and want to be able to
do both
- dynamically build/tear down new network namepsaces, without 
  unloading rds_tcp globally
- unload rds_tcp globally withouth tearing down individual netns.

But perhaps we digress.

Fundamental issue remains: newsk is the syn_recv version of the
listen socket. If the listen socket is a "kernel" socket (kern == 1
for sk_alloc, and the listen socket thus has no sk_net_refcnt),
the syn_recv socket must also have that behavior, so that it is
cleaned up in the same way.

--Sowmini
