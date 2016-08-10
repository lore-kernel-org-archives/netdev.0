From: David Howells <dhowells@redhat.com>
Subject: How best to {en,de}crypt between sk_buff and iov_iter?
Date: Wed, 10 Aug 2016 10:12:12 +0100
Message-ID: <9009.1470820332@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dhowells@redhat.com, viro@zeniv.linux.org.uk
To: netdev@vger.kernel.org, linux-crypto@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38856 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933745AbcHJSlX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 14:41:23 -0400
Content-ID: <9008.1470820332.1@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is there a good way to encrypt data held in an iov_iter directly into an
sk_buff and decrypt data held in an sk_buff back into an iov_iter?

What I would like to avoid is:

 (a) Invoking skb_cow_data() to potentially take an unnecessary copy of the
     data I shouldn't need to change, but I need to do this to decrypt in
     place.

 (b) Having to copy the unencrypted data between the sk_buff and the iov_iter
     when the crypto process ought to get me a free copy.

One problem, though, is that I might not be able to do drain/fill a complete
sk_buff in a single operation because the iov_iter might not give me sufficient
bufferage/data to do that, so it may take multiple operations.  However, since
I'm using an skcipher, I think it should be fine to call
crypto_skcipher_encrypt() multiple times on the same skcipher.

I can see a couple of alternatives:

 (1) Duplicate skb_copy_datagram_iter(), give it an initialised
     skcipher_request and let it set the crypto parameters for each block it
     transfers.  copy_to_iter() would then need to be replaced with something
     that sets up an sglist each time from the iov.

     Something similar would need doing for skb_copy_datagram_from_iter().

 (2) Create an sglist for the skb and one for the iov_iter and encrypt/decrypt
     between them.  Unfortunately, if the iov_iter is a userspace reference
     then this would mean pinning userspace pages.

 (3) Add an {en,de}crypt-to-iov_iter capability to the crypto layer.  I'm not
     sure how well this would work for hardware support, though.  I think we'd
     come back to pinning userspace pages.

David
