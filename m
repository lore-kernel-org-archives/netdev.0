From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: bind and O_NONBLOCK
Date: Sat, 22 Sep 2007 20:14:15 +0400
Message-ID: <20070922161414.GA29637@2ka.mipt.ru>
References: <46F35DD9.4000909@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Alan Cox <alan@redhat.com>
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:46773 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753957AbXIVQOd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Sep 2007 12:14:33 -0400
Content-Disposition: inline
In-Reply-To: <46F35DD9.4000909@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ulrich.

On Thu, Sep 20, 2007 at 10:59:53PM -0700, Ulrich Drepper (drepper@redhat.com) wrote:
> Some time back Alan asked about adding O_NONBLOCK support to bind in the
> POSIX spec.  I brought this up and the following text will be in the
> next revision of the POSIX spec:
> 
> =======================
> If the socket address cannot be assigned immediately and O_NONBLOCK is
> set for the file descriptor for the socket, bind( ) shall fail and set
> errno to [EINPROGRESS], but the assignment request shall not be aborted,
> and the assignment shall be completed asynchronously. Subsequent calls
> to bind() for the same socket, before the assignment is completed, shall
> fail and set errno to [EALREADY].
> 
> When the assignment has been performed asynchronously, pselect(),
> select(), and poll() shall indicate that the file descriptor for the
> socket is ready for reading and writing.
> =======================
> 
> It would be ideal if we'd have such an implementation in the next few
> months so that we, in theory, can check whether the text in the
> specification makes sense.

On behalf of which process this is supposed to be done?
Network does not have any async processing units to perform this kind 
of operations. There are four ways where bind can fail:

1. unsufficient rights - nothing can help here
2. there is no memory - async binding can not help here too, since it
	some memory just has to be allocated to save async request
	somewhere.
3. socket is locked.
4. addres is being bound is in use.

We can wait until it is released and perform binding on behalf of some 
other process in both situations, although I think we do not want 4'th
variant in some cases.

So, did I understand you correctly, that you want to introduce network
AIO here? (for example on behalf of work queue or something else?)

-- 
	Evgeniy Polyakov
