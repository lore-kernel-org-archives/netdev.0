From: Tobias DiPasquale <codeslinger@gmail.com>
Subject: Re: deleting a conntrack record
Date: Thu, 17 Jun 2004 19:03:38 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <876ef97a04061716031a0e6000@mail.gmail.com>
References: <876ef97a0406170807663b89e0@mail.gmail.com> <40D1C088.4090307@trash.net> <876ef97a04061709173c8f1a09@mail.gmail.com> <40D1C9FB.1070802@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>, linux-net <linux-net@vger.kernel.org>,
	netfilter <netfilter-devel@lists.netfilter.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <40D1C9FB.1070802@trash.net>
List-Id: netdev.vger.kernel.org

On Thu, 17 Jun 2004 18:42:35 +0200, Patrick McHardy <kaber@trash.net> wrote:
> In fact you shouldn't use ip_ct_selective_cleanup at all but destroy 
> it yourself. You already have a reference, so there is no need to 
> iterate through the entire hash.

In case anyone is interested, as a followup, the above advice works
perfectly. The code now looks like this:

<code>
static int delete_ct_record( u_int32_t src, u_int16_t sport, u_int32_t
dst, u_int16_t dport)
{
      struct ip_conntrack_tuple tuple;
      struct ip_conntrack_tuple_hash *h;

      memset( &tuple, 0, sizeof( tuple));
      tuple.src.ip = src;
      tuple.src.u.tcp.port = sport;
      tuple.dst.ip = dst;
      tuple.dst.u.tcp.port = dport;
      tuple.dst.protonum = IPPROTO_TCP;
      h = ip_conntrack_find_get( &tuple, NULL);
      if (!h)
              return -ENOENT;
      if (del_timer( &h->ctrack->timeout))
              h->ctrack->timeout.function( (unsigned long)h->ctrack);
      ip_conntrack_put( h->ctrack);
      return 1;
}
</code>

As well, the kill_ct_record() function has been removed as it is now
useless. Thanks for all the help, Patrick especially. :)

-- 
[ Tobias DiPasquale ]
0x636f6465736c696e67657240676d61696c2e636f6d
