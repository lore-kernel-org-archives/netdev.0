From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: Van Jacobson's net channels and real-time
Date: Fri, 21 Apr 2006 18:52:47 +0200
Message-ID: <200604211852.47335.netdev@axxeo.de>
References: <Pine.LNX.4.44L0.0604201819040.19330-100000@lifa01.phys.au.dk> <20060420.120955.28255828.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: simlo@phys.au.dk, linux-kernel@vger.kernel.org, mingo@elte.hu,
	netdev@vger.kernel.org, Ingo Oeser <ioe-lkml@rameria.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:28356 "EHLO mail.axxeo.de")
	by vger.kernel.org with ESMTP id S932127AbWDUQxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 12:53:08 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060420.120955.28255828.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

nice to see you getting started with it.

I'm not sure about the queue logic there.

1867 /* Caller must have exclusive producer access to the netchannel. */
1868 int netchannel_enqueue(struct netchannel *np, struct netchannel_buftrailer *bp)
1869 {
1870 	unsigned long tail;
1871
1872 	tail = np->netchan_tail;
1873 	if (tail == np->netchan_head)
1874 		return -ENOMEM;

This looks wrong, since empty and full are the same condition in your
case.

1891 struct netchannel_buftrailer *__netchannel_dequeue(struct netchannel *np)
1892 {
1893 	unsigned long head = np->netchan_head;
1894 	struct netchannel_buftrailer *bp = np->netchan_queue[head];
1895
1896 	BUG_ON(np->netchan_tail == head);

See?

What about sth. like

struct netchannel {
   /* This is only read/written by the writer (producer) */
   unsigned long write_ptr;
  struct netchannel_buftrailer *netchan_queue[NET_CHANNEL_ENTRIES];

   /* This is modified by both */
  atomic_t filled_entries; /* cache_line_align this? */

   /* This is only read/written by the reader (consumer) */
   unsigned long read_ptr;
}

This would prevent this bug from the beginning and let us still use the
full queue size.

If cacheline bouncing because of the shared filled_entries becomes an issue,
you are receiving or sending a lot.

Then you can enqueue and dequeue multiple and commit the counts later.
To be done with a atomic_read, atomic_add and atomic_sub on filled_entries.

Maybe even cheaper with local_t instead of atomic_t later on.

But I guess the cacheline bouncing will be a non-issue, since the whole
point of netchannels was to keep traffic as local to a cpu as possible, right?

Would you like to see a sample patch relative to your tree, 
to show you what I mean?


Regards

Ingo Oeser
