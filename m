From: Casey Carter <ccarter@cs.uiuc.edu>
Subject: Re: Strange UDP binding behavior (SO_BINDTODEVICE)
Date: Tue, 07 Oct 2003 15:51:57 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F83276D.3070700@cs.uiuc.edu>
References: <20031005130154.5bd9d182.kevin@pheared.net>	<3F81F1CD.8050803@Carter.net> <20031006210600.37da62c9.kevin@pheared.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Casey Carter <Casey@Carter.net>, netdev@oss.sgi.com,
        linux-ha@lists.linux-ha.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Kevin Dwyer <kevin@pheared.net>
In-Reply-To: <20031006210600.37da62c9.kevin@pheared.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Kevin Dwyer wrote:

>On Mon, 06 Oct 2003 17:50:53 -0500
>Casey Carter <Casey@Carter.net> wrote:
>
>  
>
>>This is not a bug, it's a feature!  It is possible to use multiple 
>>sockets with the same port number bound to different interfaces (where
>>"no interface" is one possible choice).  The UDP packet delivery code 
>>favors the socket that is bound to the interface through which packets
>>are received. So, if I am only interested in packets for port 6666 on 
>>eth1, then I am prioritized ahead of the socket bound to "no
>>interface" port 6666.  
>>    
>>
>
>Well, I would buy that as reasonable, acceptable behavior, but I think
>the reverse is true.
>
>We are binding specifically to say, eth0 on port 694.  Someone comes
>along and binds to "no interface" on port 694 and trumps our socket. 
>Isn't that the opposite of what you describe?
>  
>
Taking a look at the UDP delivery code in net/ipv4/udp.c (version 
2.6.0-test6) we see:

struct sock *udp_v4_lookup_longway(u32 saddr, u16 sport, u32 daddr, u16 dport, int dif)

{

    struct sock *sk, *result = NULL;

    struct hlist_node *node;

    unsigned short hnum = ntohs(dport);

    int badness = -1;


    sk_for_each(sk, node, &udp_hash[hnum & (UDP_HTABLE_SIZE - 1)]) {

        struct inet_opt *inet = inet_sk(sk);


        if (inet->num == hnum && !ipv6_only_sock(sk)) {

            int score = (sk->sk_family == PF_INET ? 1 : 0);

            if (inet->rcv_saddr) {

                if (inet->rcv_saddr != daddr)

                    continue;

                score+=2;

            }

            if (inet->daddr) {

                if (inet->daddr != saddr)

                    continue;

                score+=2;

            }

            if (inet->dport) {

                if (inet->dport != sport)

                    continue;

                score+=2;

            }

            if (sk->sk_bound_dev_if) {

                if (sk->sk_bound_dev_if != dif)

                    continue;

                score+=2;

            }

            if(score == 9) {

                result = sk;

                break;

            } else if(score > badness) {

                result = sk;

                badness = score;

            }

        }

    }

    return result;

}

This code picks a UDP socket to deliver to, amongst those with the 
correct destination port number.  It does so by ranking each socket on a 
scale from 0 to 9 and picking the first socket with the best score.   
Since the score increments are all 2, this code weights equally a socket 
that is bound to the correct interface and (for example) a socket bound 
to no interface but bound to the specific IP address the packet is 
addressed to.  IMHO, the delivery should weigh sk_bound_dev_if much more 
strongly (7 instead of 2), so that if-bound sockets are always favored 
over non-if-bound.  I would be happy to submit the (trivial) patch to do 
so if the networking gurus agree?

-- 
Casey Carter
Casey@Carter.net
ccarter@cs.uiuc.edu
AIM: cartec69
