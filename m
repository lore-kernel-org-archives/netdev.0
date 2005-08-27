From: Ben Greear <greearb@candelatech.com>
Subject: Leaked net-device reference in eql.c
Date: Fri, 26 Aug 2005 17:08:45 -0700
Message-ID: <430FAF0D.5050000@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

I think the eql_s_slave_cfg method in eql.c leaks
the reference to slave_dev.  Am I missing something?


static int eql_s_slave_cfg(struct net_device *dev, slave_config_t __user *scp)
{
	slave_t *slave;
	equalizer_t *eql;
	struct net_device *slave_dev;
	slave_config_t sc;
	int ret;

	if (copy_from_user(&sc, scp, sizeof (slave_config_t)))
		return -EFAULT;

	slave_dev = dev_get_by_name(sc.slave_name);
	if (!slave_dev)
		return -ENODEV;

	ret = -EINVAL;

	eql = netdev_priv(dev);
	spin_lock_bh(&eql->queue.lock);
	if (eql_is_slave(slave_dev)) {
		slave = __eql_find_slave_dev(&eql->queue, slave_dev);
		if (slave) {
			slave->priority = sc.priority;
			slave->priority_bps = sc.priority;
			slave->priority_Bps = sc.priority / 8;
			ret = 0;
		}
	}
	spin_unlock_bh(&eql->queue.lock);

	return ret;
}


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
