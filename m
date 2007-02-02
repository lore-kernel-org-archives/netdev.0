From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] mm: fix page_mkclean_one
Date: Fri, 02 Feb 2007 19:42:52 +1100
Message-ID: <45C2F98C.3070000@yahoo.com.au>
References: <1170369622.3453.72.camel@garangu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mark Groves <mjgroves@uwaterloo.ca>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933322AbXBBInP@vger.kernel.org>
In-Reply-To: <1170369622.3453.72.camel@garangu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Groves wrote:
> Hi,
> 
> 
> I have been been seeing a problem when using sendfile repeatedly on an
> SMP server, which I believe is related to the problem that was
> discovered recently with marking dirty pages. The bug, as well as a test
> script, is listed at http://bugzilla.kernel.org/show_bug.cgi?id=7650.
> Currently, we're experiencing errors where part of a previous packet is
> being sent out rather than the current packet.
> 
> I have applied the patch Linus posted to a 2.6.19 kernel but am still
> getting the problem. So I am wondering if there are any other places in
> the kernel which mark pages as dirty which might require a similar
> patch?

Your issue is not related, firstly because the page_mkclean bug did not
exist before 2.6.19 kernels.

Anyway, I had a look at your bugzilla test-case and managed to slim it
down to something that easily shows what the problem is (available on
request) -- the problem is that recipient of the sendfile is seeing
modifications that occur to the source file _after_ the sender has
completed the sendfile, because the file pages are not copied but
queued.

I think the usual approach to what you are trying to do is to set TCP_CORK,
then write(2) the header into the socket, then sendfile directly from the
file you want.

Another approach I guess is to implement an ack in your userland protocol
so you do not modify the sendfile source file until the client acks that
it has all the data.

I'm not sure if there are any other usual ways to do this (ie. a barrier
for sendfile, to ensure it will not pick up "future" modifications to the
file). netdev cc'ed, someone there might have additional comments.

Please close this bug if/when you are satisfied it is not a kernel problem.

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 
