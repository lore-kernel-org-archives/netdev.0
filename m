From: Sumedha Gupta <sug18@pitt.edu>
Subject: NIC Bonding mode questions
Date: Sun, 28 Jun 2009 19:41:19 -0400
Message-ID: <869c36e20906281641i7fb50d76wda57fc260eb31b91@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.249]:19677 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754823AbZF1XlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2009 19:41:16 -0400
Received: by an-out-0708.google.com with SMTP id d40so3587696and.1
        for <netdev@vger.kernel.org>; Sun, 28 Jun 2009 16:41:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In Link aggregation,  more than two NICs are bonded together to appear
as if they both are same physical device. They will both present the
same MAC address. So, the kernel will see only one device while it
sends out packets via the two slave devices using scheduling
algorithm. There are 7 bonding modes to schedule the traffic.

Linux bonding mode:
- mode 0 : round-robin
- mode 1 : active backup
- mode 2 : balance XOR : balance traffic by splitting up outgoing packets
               between the adapters using the same one for each
specific destination when possible
- mode 3 : broadcast -> sends out all traffic on every interface
- mode 4 : dynamic link aggregation, uses a complex algorithm to
aggregate adapters
              by speed and other settings.
- mode 5 : adaptive transmit load balancing, redistributes outgoing
traffic on the fly
              based on current conditions.
- mode 6 : adaptive load balancing, does the same thing, but attempts
to redistribute
              incoming traffic as well by sending out ARP updates.


static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device
*bond_dev)
{
        struct bonding *bond = netdev_priv(bond_dev);
4300        struct slave *slave, *start_at;
4301        int i, slave_no, res = 1;
4302
4303        read_lock(&bond->lock);
4304
4305        if (!BOND_IS_OK(bond)) {
4306                goto out;
4307        }
4308
4309        /*
4310         * Concurrent TX may collide on rr_tx_counter; we accept that
4311         * as being rare enough not to justify using an atomic op here
4312         */
4313        slave_no = bond->rr_tx_counter++ % bond->slave_cnt;
4314
4315        bond_for_each_slave(bond, slave, i) {
4316                slave_no--;
4317                if (slave_no < 0) {
4318                        break;
4319                }
4320        }
4321
4322        start_at = slave;
4323        bond_for_each_slave_from(bond, slave, i, start_at) {
4324                if (IS_UP(slave->dev) &&
4325                    (slave->link == BOND_LINK_UP) &&
4326                    (slave->state == BOND_STATE_ACTIVE)) {
4327                        res = bond_dev_queue_xmit(bond, skb, slave->dev);
4328                        break;
4329                }
4330        }
4331
4332 out:
4333        if (res) {
4334                /* no suitable interface, frame not sent */
4335                dev_kfree_skb(skb);
4336        }
4337        read_unlock(&bond->lock);
4338        return 0;
4339 }
4340
4341

4372
4373/*
4374 * In bond_xmit_xor() , we determine the output device by using a pre-
4375 * determined xmit_hash_policy(), If the selected device is not enabled,
4376 * find the next active slave.
4377 */
4378static int bond_xmit_xor(struct sk_buff *skb, struct net_device *bond_dev)
4379{
4380        struct bonding *bond = netdev_priv(bond_dev);
4381        struct slave *slave, *start_at;
4382        int slave_no;
4383        int i;
4384        int res = 1;
4385
4386        read_lock(&bond->lock);
4387
4388        if (!BOND_IS_OK(bond)) {
4389                goto out;
4390        }
4391
4392        slave_no = bond->xmit_hash_policy(skb, bond_dev, bond->slave_cnt);
4393
4394        bond_for_each_slave(bond, slave, i) {
4395                slave_no--;
4396                if (slave_no < 0) {
4397                        break;
4398                }
4399        }
4400
4401        start_at = slave;
4402
4403        bond_for_each_slave_from(bond, slave, i, start_at) {
4404                if (IS_UP(slave->dev) &&
4405                    (slave->link == BOND_LINK_UP) &&
4406                    (slave->state == BOND_STATE_ACTIVE)) {
4407                        res = bond_dev_queue_xmit(bond, skb, slave->dev);
4408                        break;
4409                }
4410        }
4411
4412out:
4413        if (res) {
4414                /* no suitable interface, frame not sent */
4415                dev_kfree_skb(skb);
4416        }
4417        read_unlock(&bond->lock);
4418        return 0;
4419}
4420

Please help me understand:
- Why do we need "balance XOR" over "round-robin"? What are the main
differences?
- What is "adaptive load balancing" and "adaptive transmit load balancing"?
 - How should we decide which mode is better for a particular purpose?

I will really appreciate if someone can help me answer these questions.

These are the related article and code:
http://www.linux.com/archive/feature/133849
http://lxr.linux.no/linux+v2.6.29/drivers/net/bonding/bond_main.c

Thanks,
Sumedha
