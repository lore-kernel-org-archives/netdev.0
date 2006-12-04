From: home_king <home_king@163.com>
Subject: Re: [PATCH] [IPVS] transparent proxying
Date: Mon, 04 Dec 2006 13:53:35 +0800
Message-ID: <4573B7DF.70002@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David Miller" <davem@davemloft.net>,
	"Julian Anastasov" <ja@ssi.bg>,
	"Joseph Mack NA3T" <jmack@wm7d.net>,
	"Jinhua Luo" <home_king@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-16.163.com ([220.181.12.16]:19137 "HELO m12-16.163.com")
	by vger.kernel.org with SMTP id S933793AbWLDF4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 00:56:39 -0500
To: "Wensong Zhang" <wensong@linux-vs.org>,
	"Horms" <horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > I am afraid that the method used in the patch is not native, it breaks
 > on IP fragments.
 > IPVS is a kind of layer-4 switching, it routes packet by checking
 > layer-4 information
 > such as address and port number. ip_vs_in() is hooked at 
NF_IP_LOCAL_IN, so
 > that all the packets received by ip_vs_in() are already defragmented. On
 > NF_IP_FORWARD
 > hook, there may be some IP fragements, ip_vs_in() cannot handle those IP
 > fragments.

However, your analysis is a bit inaccurate, I think.

As far as I know, Policy route's conjunction with fwmark works just under
some precondition, the most important one of which is defragmentation
function provided by NF_CONNTRACK. That is, the routing core works in
layer 3, and it can even route all IP fragments just by the IP info, and
doesn't care about the layer 4 info, such as service ports. Firewall Mark
makes layer 4 involved. To retrieve the full layer 4 header, netfilter
has no choice but to do defragmentation for the routing core, which is the
key function of NF_CONNTRACK.

In a word, without NF_CONNTRACK, neither the policy route nor my patch, can
face the defragmentation problem!

I will give you some proof of my words.

LOOKING at the NETFILTER SOURCE:

See the below quotation form /usr/include/linux/netfilter_ipv4.h, the
defragmentation of netfilter owns the highest prority, so the corresponding
hook will be called before any other hooks including ipvs & iptables.

-----quote start-----
enum nf_ip_hook_priorities {
        NF_IP_PRI_FIRST = INT_MIN,
        NF_IP_PRI_CONNTRACK_DEFRAG = -400,
    ...
        NF_IP_PRI_LAST = INT_MAX,
};
-----quote end-----


And see ip_conntrack_standalone.c, here defines the defrag hooks on
PREROUTING chain and OUTPUT chain with NF_IP_PRI_CONNTRACK_DEFRAG
prority. Needless to say, all packets which flow on INPUT & FORWARD
chain are already defragmented by it; In other word, once the CONNTRACK
is enabled, you cannot see any fragment in INPUT & FORWARD chain, even
the other chains.

-----quote start-----
static struct nf_hook_ops ip_conntrack_defrag_ops = {
    .hook        = ip_conntrack_defrag,
    .owner        = THIS_MODULE,
    .pf        = PF_INET,
    .hooknum    = NF_IP_PRE_ROUTING,
    .priority    = NF_IP_PRI_CONNTRACK_DEFRAG,
};

static struct nf_hook_ops ip_conntrack_defrag_local_out_ops = {
    .hook        = ip_conntrack_defrag,
    .owner        = THIS_MODULE,
    .pf        = PF_INET,
    .hooknum    = NF_IP_LOCAL_OUT,
    .priority    = NF_IP_PRI_CONNTRACK_DEFRAG,
};
-----quote end-----


On the other hand, I wrote a simply program -- test_udp_fragment.c
to test it.

-----test code start--------------

#include <sys/types.h>
#include <sys/socket.h>
#include <errno.h>
#include <stdlib.h>
#include <linux/in.h>

int main(int argc, char *argv[])
{
#ifndef AS_SERVER
    if (argc < 2) {
        printf("SYNTAX: %s <server ip>\n", argv[0]);
        exit(EXIT_SUCCESS);
    }
#endif

    int sockfd;
    sockfd = socket(PF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0) {
        perror("socket");
        exit(EXIT_FAILURE);
    }
#define MSG_SIZE 10000          /* bigger than MTU */
#define BUF_SIZE MSG_SIZE+1

    char buf[BUF_SIZE];
    memset(buf, 0, BUF_SIZE);

    struct sockaddr_in test_addr;
    test_addr.sin_family = AF_INET;
    test_addr.sin_port = htons(10000);
#ifdef AS_SERVER
    test_addr.sin_addr.s_addr = inet_addr("0.0.0.0");
    if (bind(sockfd,
             (struct sockaddr *) &test_addr, sizeof(test_addr)) < 0) {
        perror("bind");
        exit(EXIT_FAILURE);
    }
    ssize_t r = 0;

    while (1) {
        r = recv(sockfd, buf, MSG_SIZE, MSG_WAITALL);
        if (r < MSG_SIZE) {
            printf("truncated!\n");
            exit(EXIT_FAILURE);
        }
        printf("recv message: %s\n", buf);
    }
#else
    memset(buf, 'A', MSG_SIZE);

    test_addr.sin_addr.s_addr = inet_addr(argv[1]);
    ssize_t s = 0;
    s = sendto(sockfd, buf, MSG_SIZE, 0, (struct sockaddr *) &test_addr,
               sizeof(test_addr));
    if (s != MSG_SIZE) {
        perror("send failed");
        exit(EXIT_FAILURE);
    }
#endif

    exit(EXIT_SUCCESS);
}
-----test code end--------------

The program above implements a simple udp server & a simple udp client.

The client sends a message of MSG_SIZE bytes (which is filled with 'A') to
the server, and the server receives and prints out the message.

The MSG_SIZE (Here I takes 10000 as example) is far bigger than the
normal Ethernet NIC MTU (1500), so the output message will be fragmented.

Given the IP (SIP) of server is 172.16.100.254, and the IP of client (CIP)
is 172.16.100.63. The Default Gateway IP of client is SIP.

I do the below settings:

@ Server

# Mark the client's udp access
iptables -t mangle -A PREROUTING -p udp -s 172.16.100.63 --dport 10000 \
  -j MARK --set-mark 1
# REDIRECT the forward packets marked with 1 to localhost
ip rule add prio 100 fwmark 1 table 100
ip route add local 0/0 dev lo table 100
# Compile the test program and copy them to the place
gcc  -DAS_SERVER -o /tmp/server test_udp_fragment.c
gcc  -o /tmp/client test_udp_fragment.c
scp test_udp_fragment.c 172.16.100.63:/tmp/
# Start the server
/tmp/server

@ Client

# Send a message to some site of external network, such as google.com
/tmp/client 64.233.189.104


The test has two different result:
1. When the CONNTRACK is enabled in the kernel running on the server
recv message: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAA....

2. When the CONNTRACK is disabled in the kernel running on the server
[Nothing printed out!!!]

See, without CONNTRACK, the policy route failed to handle the
defragmentation problem too! In fact, it just routes the first IP
fragment of the message to the INPUT chain, and ignores the other
IP fragments and let them wander on the FORWARD chain, so the
defragmentation job of ip_local_deliver() will never success.
And the upper test program will never receive the message from kernel.


Besides this test program, you can simply validate this fact through
iptables LOG target:

@ Server

# Set a LOG rule just after the MARK rule
iptables -t mangle -A PREROUTING -m mark --mark 1 -j LOG

you will see that, without CONNTRACK, you see the first IP fragment
packet in your log file, and with CONNTRACK, you see an entire IP packet!




All in all, the conclusion is that:
If you use CONNTRACK, my TP patch works without defragmentation problem;
If you don't use CONNTRACK, both my TP patch & Policy routing rule for TP
do not work!

So, I always think that, my patch enables the native support for TP.


Cheers,

Jinhua

