From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Wed, 16 Mar 2005 11:47:34 +0100
Message-ID: <42380EC6.60100@cosmosbay.com>
References: <42370997.6010302@cosmosbay.com> <20050315103253.590c8bfc.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050315103253.590c8bfc.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

After having hard times tuning /proc/sys/net/ipv4/route/* values, with various crashes of production machines,
I did some investigations...

The rt_check_expire() has a serious problem on machines with large route caches, and a standard HZ value of 1000.

With default values, ie ip_rt_gc_interval = 60*HZ = 60000 ;

the loop count :

     for (t = ip_rt_gc_interval << rt_hash_log; t >= 0;


overflows (t is a 31 bit value) as soon rt_hash_log is >= 16  (65536 slots in route cache hash table)

Another problem is the fact that this function has close to 0 effect, because even if ip_rt_gc_interval is changed to 1 HZ,
only 1/300 of the table is scanned every second. And the loop breaks as soon a jiffie is consumed.

We should adapt the loop count based on the actual number of entries in the route cache,
and eventually give more 'jiffies' in some pressure cases.

I am experimenting some changes that I will share when ready.


Thank you
Eric Dumazet
