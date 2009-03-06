From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: Query about skb scatter / gather
Date: Fri, 6 Mar 2009 11:47:22 -0800
Message-ID: <F169D4F5E1F1974DBFAFABF47F60C10A1E6EB189@orsmsx507.amr.corp.intel.com>
References: <c8028d330903060917r4af01c7ew2426bcb30af90b5e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: Amar Mudrankit <amar.mudrankit@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:39571 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754282AbZCFTr0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2009 14:47:26 -0500
In-Reply-To: <c8028d330903060917r4af01c7ew2426bcb30af90b5e@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Amar Mudrankit wrote:
> Can I have a socket buffer received over network having protocol
> headers (IP, TCP/UDP/ICMP) in first page of skb_frags_t array of the
> skb?
> 
> So, in such a situation the skb->data is almost 0 and all the data
> along with headers is in pages listed in skb_frags_t array.
> 
> Can linux networking stack handle such socket buffer? Or is it
> mandatory that, at least some minimum data should be accessible
> through skb->data and rest can be in pages described in skb_frags_t
> array?

the answer is yes, but see below.
 
> Also can anyone suggest good pointers for making use of frag_list in
> skb_shared_info structure? Is it meant to represent one network packet
> as the list of multiple skbs each skb holding part of packet data in
> the order they are linked?

frag_list can only be safely used in rare cases where you know that 
the ip defragmentation code will not be called.  It links multiple
skb's together to form one large packet (for receive)
 
> I tried finding it in UNDERSTANDING LINUX NETWORK INTERNALS by
> CHRISTIAN BENVENUTI, but couldn't find anything conclusive.  As I
> understand, it is enabled through NETIF_F_FRAGLIST feature of the
> device.

The Intel ixgbe, igb, and e1000e drivers all support receiving
packets into two buffers, the header into the first buffer and the
data into the first page, second page, etc.

the pages are stored in skb_shinfo(skb)->frags[]

for most working protocols in the kernel the ->data section is populated
if necessary by pskb_may_pull and friends

AFAIK the myri10ge driver receives only into pages and then has to
build a receivable sk_buff (using an open coded pskb_pull_tail)

hope this helps,
  Jesse